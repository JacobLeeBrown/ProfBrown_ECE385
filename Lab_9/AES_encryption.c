/*---------------------------------------------------------------------------
  --      hello_world.c                                                    --
  --      Christine Chen                                                   --
  --      Fall 2013														   --
  --																	   --
  --      Updated Spring 2015 											   --
  --	  Yi Liang														   --
  --																	   --
  --      For use with ECE 385 Experiment 9                                --
  --      UIUC ECE Department                                              --
  ---------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include "aes.h"

#define to_hw_port 	(char*) 			0x00000050
#define to_hw_sig 	(char*) 			0x00000040
#define to_sw_port 	(volatile char*) 	0x00000030
#define to_sw_sig 	(volatile char*) 	0x00000020

#define N_ROUNDS 		10		// self-defined constant (Jacob)
#define N_COLS   		4 		// self-defined constant (Jacob)
#define N_WORDS_CIPHER	4		// self-defined constant (Jacob)

/* ~~~ Helper functions ~~~ */

/* Functions that turn characters into hex values */

char charToHex(char c)
{	
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <='F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <='f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

unsigned char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

/* Our defined helper functions */

// Takes four Bytes and returns a word comstructed from them
WORD make_word(BYTE b1, BYTE b2, BYTE b3, BYTE b4)
{
	WORD w = 0x01000000 * b1 +
			 0x00010000 * b2 +
			 0x00000100 * b3 +
			 0x00000001 * b4;
	return w;
}

// Prints state in 4 x 4 Byte column-major order
void print_state(BYTE * state)
{
	printf("%02x %02x %02x %02x\n", state[0], state[4], state[8], state[12]);
	printf("%02x %02x %02x %02x\n", state[1], state[5], state[9], state[13]);
	printf("%02x %02x %02x %02x\n", state[2], state[6], state[10], state[14]);
	printf("%02x %02x %02x %02x\n", state[3], state[7], state[11], state[15]);
	printf ("\n");
}

// Prints specified RoundKey of the Key Schedule
void print_key_schedule(WORD* ks, int index)
{
	int i;
	for(i = 0; i < 4; i++)
		BYTE b0 = ks[index] >> (8 * i) & 0x00FF;		//Grab the least significant byte
		BYTE b1 = (ks[index+1] >> (8 * i)) & 0x00FF;	//Grab the second byte
		BYTE b2 = (ks[index+2] >> (8 * i)) & 0x00FF;	//Grab the third byte
		BYTE b3 = (ks[index+3] >> (8 * i)) & 0x00FF;	//Grab the most significant byte
		printf("%02x %02x %02x %02x\n", b0, b1, b2, b3);
}

// AES Encryption related function calls

/**
 * AddRoundKey
 * XORs each Byte with the corresponding Byte from the current RoundKey
 * – Each Round of the algorithm uses different RoundKeys
 * – Each RoundKey is generated from the previous RoundKey
 * – RoundKeys can be generated either altogether at the beginning of the AES algorithm,
 *   or during each round
 */
void AddRoundKey(BYTE *state, WORD * round_key_start)
{
	int i;
	// for all 16 bytes in State and the current round_key
	for(i = 0; i < (4 * N_COLS); i++)
	{
		// update state's bytes by XOR-ing with corresponding round_key byte
		state[i] ^= round_key_start[i];
	}
}

BYTE subByte(BYTE b)
{
	//break each byte into 2 nibbles
	BYTE b_L = b & 0x000F;
	BYTE b_M = (0 >> 4) & 0x000F;

	//get results - "first nibble in the first index (row),
	//				 second nibble in the second index (column)"
	BYTE subbed = aes_sbox[b_M][b_L];

	return subbed;
}

/**
 * SubWord
 * Same as SubBytes(), but acts only on a single word at a time
 */
void SubWord(WORD *w)
{
	BYTE b0 = *w & 0x00FF;			//Grab the least significant byte
	BYTE b1 = (*w >> 8) & 0x00FF;	//Grab the second byte
	BYTE b2 = (*w >> 16) & 0x00FF;	//Grab the third byte
	BYTE b3 = (*w >> 24) & 0x00FF;	//Grab the most significant byte

	//combine results - r1 is least significant byte, r4 is most significant byte
	*w = make_word(subByte(b0), subByte(b1), subByte(b2), subByte(b3));
}

/**
 * SubBytes
 * Substitutes bytes of the current state based on the Rijndael S-box
 */
void SubBytes(BYTE *state)
{
	int i;
	// For every byte in the current state, replace it with
	// the corresponding byte from the Rijndael S-Box matrix
	for(i = 0; i < (4*N_COLS); i++)
	{
		state[i] = subByte(state[i]);
	}
}

/**
 * RotWord
 * Rotates 4-Byte word left
 */
void RotWord(WORD *w)
{
	WORD temp = 0x00000000;		//Create an empty 4-byte temp variable
	temp = *w & 0xFF000000;		//Bit-mask first byte of word w and store in temp
	temp >>= 24;				//Shift temp right by 3 bytes
	*w <<= 8;					//Shift word w by 1 byte
	*w |= temp;					//Logical OR such that word w now has the first byte
								//moved to the last byte
}

/**
 * MixColumns
 * Multiply each column by matrix as shown in GF(2^8)
 * MixColumns performs matrix multiplication with each Word
 * 	wi = {a(0,i),a(1,i), a(2,i),a(3,i)}^Transpose under Rijndael’s finite field
 * – ({02} dot a) can be implemented by bit-wise left shift then a conditional
 *    bitwise XOR with {1b} if the 8th bit before the shift is 1
 * – It is also possible to use a pre-computed lookup table gf_mul[256][6]
 */
void MixColumns(BYTE *state)
{
	int i;
	for(i = 0; i < (4*N_COLS); i+=4){
		BYTE bi0 = gf_mul[state[i]][0] ^ gf_mul[state[i+1]][1] ^ state[i+2] ^ state[i+3];
		BYTE bi1 = state[i] ^ gf_mul[state[i+1]][0] ^ gf_mul[state[i+2]][1] ^ state[i+3];
		BYTE bi2 = state[i] ^ state[i+1] ^ gf_mul[state[i+2]][0] ^ gf_mul[state[i+3]][1];
		BYTE bi3 = gf_mul[state[i]][1] ^ state[i+1] ^ state[i+2] ^ gf_mul[state[i+3]][0];

		state[i] = bi0;
		state[i+1] = bi1;
		state[i+2] = bi2;
		state[i+3] = bi3;
	}
}

void ShiftRow_1Byte(BYTE *x0, BYTE *x1, BYTE *x2, BYTE *x3)
{
	BYTE x0_temp = *x0;
	*x0 = *x1;
	*x1 = *x2;
	*x2 = *x3;
	*x3 = x0_temp;
}

void ShiftRow_2Byte(BYTE *x0, BYTE *x1, BYTE *x2, BYTE *x3)
{
	BYTE x0_temp = *x0;
	BYTE x1_temp = *x1;
	*x0 = *x2;
	*x1 = *x3;
	*x2 = x0_temp;
	*x3 = x1_temp;
}

void ShiftRow_3Byte(BYTE *x0, BYTE *x1, BYTE *x2, BYTE *x3)
{
	BYTE x3_temp = *x3;
	*x3 = *x2;
	*x2 = *x1;
	*x1 = *x0;
	*x0 = x3_temp;
}

void ShiftRows(BYTE *state)
{
	ShiftRow_1Byte(&state[1], &state[5], &state[9], &state[13]);
	ShiftRow_2Byte(&state[2], &state[6], &state[10], &state[14]);
	ShiftRow_3Byte(&state[3], &state[7], &state[11], &state[15]);
}

/**
 * KeyExpansion
 * Generates a RoundKey at a time based on the previous RoundKey (use the Cipher Key
 * to generate the first RoundKey)
 * – RotWord() – circularly shift each Byte in a Word up by 1 Byte
 * – SubWord() – identical to SubBytes()
 * – Rcon() – xor the Word with the corresponding Word from the Rcon lookup table
 */
void KeyExpansion(BYTE key[33], WORD *w, int Nk){
	int i;
	// Assign the key to the first Round Key in key_schedule
	for(i = 0; i < Nk; i++)
	{
		// Since key is just an array of bytes, construct the word from individual bytes
		// and assign it to the respective word in the key_schedule
		w[i] = make_word(key[4*i], key[4*i+1], key[4*i+2], key[4*i+3]);
	}
	//	for every following word in key_schedule
	for(i = Nk; i < N_COLS*(N_ROUNDS+1); i++)
	{
		// temp will hold the previous word
		WORD wtemp = w[i-1];
		// if the current word is the first word of a round key
		if(i % Nk == 0)
		{
			//printf("");
			// run special algorithm for first word of a round key
			RotWord(&wtemp);
			SubWord(&wtemp);
			wtemp ^= Rcon[i / Nk];
		}
		// assign the appropriately modified word to the corresponding word in the key_schedule
		w[i] = w[i-1] ^ wtemp;
	}
}

int main()
{
	int i;
	// 33 instead of 32 Bytes because of addition of newline character at the end
	BYTE plaintext[33]; 
	BYTE key[33];

	// Start with pressing reset
	*to_hw_sig = 0;
	*to_hw_port = 0;
	printf("Press reset!\n");
	while (*to_sw_sig != 3);

	while (1)
	{
		*to_hw_sig = 0;
		printf("\n");

		// Acquire the original message
		printf("\nEnter message:\n");
		scanf ("%s", plaintext);
		printf("\nTransmitting message...\n");
		for (i = 0; i < 32; i+=2)
		{
			//printf("Checking byte: %d = %02x\n", i/2, charsToHex(plaintext[i], plaintext[i+1])&0xFF);
			*to_hw_sig = 1;
			*to_hw_port = charsToHex(plaintext[i], plaintext[i+1]);
			while (*to_sw_sig != 1);
			*to_hw_sig = 2;
			while (*to_sw_sig != 0);
		}
		printf ("\n");
		*to_hw_sig = 0;	// Set HW signal to 0 to exit READ_MSG/MSG_ACK loop

		// Convert 32 Byte plaintext to condensed 16 Byte state
		BYTE state[4 * N_COLS];
		for(i = 0; i < (4 * N_COLS); i++)
		{
			state[i] = charsToHex(plaintext[2*i], plaintext[2*i+1]);
		}

		// Acquire the original key
		printf("\nEnter cipher:\n");
		scanf ("%s", cipher);
		printf("\nTransmitting cipher...\n");
		for (i = 0; i < 32; i+=2)
		{
			// printf("Checking byte: %d = %02x\n", i/2, charsToHex(cipher[i], cipher[i+1])&0xFF);
			*to_hw_sig = 2;
			*to_hw_port = charsToHex(key[i], key[i+1]);
			while (*to_sw_sig != 1);
			*to_hw_sig = 1;
			while (*to_sw_sig != 0);
		}
		printf ("\n");
		*to_hw_sig = 3;	// Set HW signal to 3 to exit READ_KEY/KEY_ACK loop

		// Convert 32 Byte cipher to condensed 16 Byte key
		BYTE key[4 * N_WORDS_CIPHER];
		for(i = 0; i < (4 * N_WORDS_CIPHER); i++)
		{
			key[i] = charsToHex(cipher[2*i], cipher[2*i+1]);
		}

		// Instantiate key_schedule and populate with KeyExpansion
		WORD key_schedule[N_COLS*(N_ROUNDS+1)];
		KeyExpansion(key, key_schedule, N_WORDS_CIPHER);
		// Debugging method to print any RoundKey in the schedule
		print_key_schedule(key_schedule, 0);

		/* 
		 * AES(byte plaintext[4*N_COLS], byte cipher[4*N_COLS], word w[N_COLS*(N_ROUNDS+1)])
		 * Nr = N_ROUNDS = 10, Nb = N_COLS = 4, in = plaintext, out = cipher, w = Cipher Key
		 */
		AddRoundKey(state, &key_schedule[0]);
		int round;
		for(round = 1; round <= N_ROUNDS-1; round++)
		{
			SubBytes(state);
			ShiftRows(state);
			MixColumns(state);
			AddRoundKey(state, &key_schedule[round * N_COLS]);
		}
		SubBytes(state);
		ShiftRows(state);
		AddRoundKey(state, &key_schedule[N_ROUNDS * N_COLS]);

		// Display the encrypted message.
		printf("\nEncrypted message is\n");
		for(i = 0; i < 32; i+=2)
		{
			printf("%02x", charsToHex(state[i], state[i+1]) & 0xFF);
		}


		// ~~~ All Week 2 ~~~ (Jacob)

		// Transmit encrypted message to hardware side for decryption.
		/*printf("\nTransmitting message...\n");

		for (i = 0; i < 16; i++)
		{
			*to_hw_sig = 1;
			*to_hw_port = encryptedMsg[i]; // encryptedMsg is your encrypted message
			// Consider to use charToHex() if your encrypted message is a string.
			while (*to_sw_sig != 1);
			*to_hw_sig = 2;
			while (*to_sw_sig != 0);
		}
		*to_hw_sig = 0;

		// Transmit encrypted message to hardware side for decryption.
		printf("\nTransmitting key...\n");

		//TODO: Transmit key

		printf("\n\n");

		while (*to_sw_sig != 2);
		printf("\nRetrieving message...\n");
		for (i = 0; i < 16; ++i)
		{
			*to_hw_sig = 1;
			while (*to_sw_sig != 1);
			str[i] = *to_sw_port;
			*to_hw_sig = 2;
			while (*to_sw_sig != 0);
		}

		printf("\n\n");

		printf("Decoded message:\n");

		// TODO: print decoded message*/
	}
	return 0;
}
