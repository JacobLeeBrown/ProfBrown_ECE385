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
#include "aes.c"

#define to_hw_port (volatile char*) 0x00000050
#define to_hw_sig (volatile char*) 	0x00000040
#define to_sw_port (char*) 			0x00000030
#define to_sw_sig (char*) 			0x00000020

#define N_ROUNDS 		10		// self-defined constant (Jacob)
#define N_COLS   		4 		// self-defined constant (Jacob)
#define N_WORDS_CIPHER	4		// self-defined constant (Jacob)

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

char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

WORD make_word(BYTE b1, BYTE b2, BYTE b3, BYTE b4)
{
	WORD w = 0x01000000 * b1 +
			 0x00010000 * b2 +
			 0x00000100 * b3 +
			 0x00000001 * b4;
	return w;
}

// TODO: AES Encryption related function calls

/**
 * AddRoundKey
 * XORs each Byte with the corresponding Byte from the current RoundKey
 * � Each Round of the algorithm uses different RoundKeys
 * � Each RoundKey is generated from the previous RoundKey
 * � RoundKeys can be generated either altogether at the beginning of the AES algorithm,
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

/**
 * SubWord
 * Same as SubBytes(), but acts only on a single word at a time
 */
void SubWord(WORD *w)
{
	BYTE b1 = *w & 0x00FF;			//Grab the least significant byte
	BYTE b2 = (*w >> 8) & 0x00FF;	//Grab the second byte
	BYTE b3 = (*w >> 16) & 0x00FF;	//Grab the third byte
	BYTE b4 = (*w >> 24) & 0x00FF;	//Grab the most significant byte

	//break each byte into 2 nibbles
	BYTE b1_L = b1 & 0x000F;
	BYTE b1_M = (b1 >> 4) & 0x000F;
	BYTE b2_L = b2 & 0x000F;
	BYTE b2_M = (b2 >> 4) & 0x000F;
	BYTE b3_L = b3 & 0x000F;
	BYTE b3_M = (b3 >> 4) & 0x000F;
	BYTE b4_L = b4 & 0x000F;
	BYTE b4_M = (b4 >> 4) & 0x000F;

	//get results - "first nibble in the first index (row),
	//				 second nibble in the second index (column)"
	BYTE r1 = aes_sbox[b1_M][b1_L];
	BYTE r2 = aes_sbox[b2_M][b2_L];
	BYTE r3 = aes_sbox[b3_M][b3_L];
	BYTE r4 = aes_sbox[b4_M][b4_L];

	//combine results - r1 is least significant byte, r4 is most significant byte
	*w = (r4 << 24) | (r3 << 16) | (r2 << 8) | (r1);
}

/**
 * SubBytes
 * Substitutes bytes of the current state based on the Rijndael S-box
 */
void SubBytes(BYTE *state)
{

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

void MixColumns(BYTE *state)
{

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
	ShiftRow_1Byte(state[1], state[5], state[9], state[13]);
	ShiftRow_2Byte(state[2], state[6], state[10], state[14]);
	ShiftRow_3Byte(state[3], state[7], state[11], state[15]);
}

/**
 * KeyExpansion
 * Generates a RoundKey at a time based on the previous RoundKey (use the Cipher Key
 * to generate the first RoundKey)
 * � RotWord() � circularly shift each Byte in a Word up by 1 Byte
 * � SubWord() � identical to SubBytes()
 * � Rcon() � xor the Word with the corresponding Word from the Rcon lookup table
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
	// int i; // Unused for week 1, may be needed in week 2 (Jacob)
	BYTE plaintext[33]; //should be 1 more character to account for string terminator
	BYTE key[33];
	BYTE cipher[33];

	// Start with pressing reset
	*to_hw_sig = 0;
	*to_hw_port = 0;
	printf("Press reset!\n");
	while (*to_sw_sig != 3);

	while (1)
	{
		*to_hw_sig = 0;
		printf("\n");

		printf("\nEnter plain text:\n");
		scanf ("%s", plaintext);
		printf ("\n");
		printf("\nEnter key:\n");
		scanf ("%s", key);
		printf ("\n");

		WORD key_schedule[N_COLS*(N_ROUNDS+1)];
		KeyExpansion(cipher, &key_schedule[0], N_WORDS_CIPHER);

		// TODO: Key Expansion and AES encryption using week 1's AES algorithm.
		// AES(byte plaintext[4*N_COLS], byte cipher[4*N_COLS], word w[N_COLS*(N_ROUNDS+1)])
		// Nr = N_ROUNDS = 10, Nb = N_COLS = 4, in = plaintext, out = cipher, w = Cipher Key
		BYTE state[(4 * N_COLS) + 1];
		// strcpy(state , plaintext);
		// state = plaintext;
		AddRoundKey(&plaintext[0], &key_schedule[0]);
		int round;
		for(round = 1; round <= N_ROUNDS-1; round++)
		{
			SubBytes(&plaintext[0]);
			ShiftRows(&plaintext[0]);
			MixColumns(&plaintext[0]);
			AddRoundKey(&plaintext[0], &key_schedule[round * N_COLS]);
		}
		SubBytes(state);
		ShiftRows(state);
		AddRoundKey(state, &key_schedule[N_ROUNDS * N_COLS]);
		// cipher = state + "\n";


		// TODO: display the encrypted message.
		printf("\nEncrypted message is\n");

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
