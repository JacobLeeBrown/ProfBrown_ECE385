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
#include <string.h>
#include <time.h>
#include "aes.h"

#define to_hw_port 	(char*) 			0x00000050
#define to_hw_sig 	(char*) 			0x00000040
#define to_sw_port 	(volatile char*) 	0x00000030
#define to_sw_sig 	(volatile char*) 	0x00000020

#define N_ROUNDS 		10		// The number of total rounds in the AES Encryption algorithm
#define N_COLS   		4 		// The number of columns in a state
#define N_WORDS_CIPHER	4		// The number of 32-bit words in the Cipher Key
#define ITERATIONS		100	00	// Number of times to run the algorithm

/**********************************************/
/**         ~~~ Helper Functions ~~~         **/
/**********************************************/

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

/**
 * Takes four Bytes and constructs a 4-Byte word out of them.
 *
 * @param b1 Byte that will be bits [31:24] of the constructed word
 * @param b2 Byte that will be bits [23:16] of the constructed word
 * @param b3 Byte that will be bits [15:8] of the constructed word
 * @param b4 Byte that will be bits [7:0] of the constructed word
 */
WORD make_word(BYTE b1, BYTE b2, BYTE b3, BYTE b4)
{
	WORD w = 0x01000000 * b1 +
			 0x00010000 * b2 +
			 0x00000100 * b3 +
			 0x00000001 * b4;
	return w;
}

/**
 * Prints a 4-Byte hexadeximal word Byte by Byte.
 * 
 * @param w The word to be printed
 */
void print_word(WORD *w)
{
	BYTE b0 = *w & 0x00FF;			//Grab the least significant byte
	BYTE b1 = (*w >> 8) & 0x00FF;	//Grab the second byte
	BYTE b2 = (*w >> 16) & 0x00FF;	//Grab the third byte
	BYTE b3 = (*w >> 24) & 0x00FF;	//Grab the most significant byte

	printf("%02x %02x %02x %02x\n", b3, b2, b1, b0);
}

/**
 * Prints a 16-Byte array in 4x4 Byte column-major order.
 * 
 * @param state The state to be printed
 */
void print_state(BYTE * state)
{
	printf("%02x %02x %02x %02x\n", state[0], state[4], state[8], state[12]);
	printf("%02x %02x %02x %02x\n", state[1], state[5], state[9], state[13]);
	printf("%02x %02x %02x %02x\n", state[2], state[6], state[10], state[14]);
	printf("%02x %02x %02x %02x\n", state[3], state[7], state[11], state[15]);
	printf ("\n");
}

/**
 * Prints a 16-Byte Roundkey in 4x4 Byte column-major order.
 * 
 * @param ks The KeySchedule
 * @param index The start of the desired round in the KeySchedule array
 */
void print_key_schedule(WORD* ks, int index)
{
	int i;
	for(i = 0; i < 4; i++)
	{
		BYTE b0 = (ks[(4*index)] >> (24 - (8 * i))) & 0xFF;		// Correct byte from the first Word
		BYTE b1 = (ks[(4*index)+1] >> (24 - (8 * i))) & 0xFF;	// Correct byte from the second Word
		BYTE b2 = (ks[(4*index)+2] >> (24 - (8 * i))) & 0xFF;	// Correct byte from the third Word
		BYTE b3 = (ks[(4*index)+3] >> (24 - (8 * i))) & 0xFF;	// Correct byte from the fourth Word
		printf("%02x %02x %02x %02x\n", b0, b1, b2, b3);
	}
	printf("\n");
}

/**********************************************/
/** ~~~ AES Encryption related functions ~~~ **/
/**********************************************/

/**
 * Returns the designated Byte using the Rijndael S-Box.
 *
 * @param b The Byte that defines the index of the substituting Byte
 *
 * @return The proper Byte from the Rijndael S-Box
 */
BYTE subByte(BYTE b)
{
	//break each byte into 2 nibbles
	BYTE b_L = b & 0x000F;
	BYTE b_M = (b >> 4) & 0x000F;

	//get results - "first nibble in the first index (row),
	//				 second nibble in the second index (column)"
	return aes_sbox[b_M][b_L];
}

/**
 * Rotates a 4-Byte word circularly left by 1 Byte.
 *
 * @param w The word to shift
 */
void RotWord(WORD *w)
{
	WORD temp = 0x00000000;		// Create an empty 4-byte temp variable
	temp = *w & 0xFF000000;		// Bit-mask first byte of word w and store in temp
	temp >>= 24;				// Shift temp right by 3 bytes
	*w <<= 8;					// Shift word w by 1 byte
	*w &= 0xFFFFFFFF;			// Bit-mask whole word to remove access bits
	*w |= temp;					// Logical OR such that word w now has the first byte
								// moved to the last byte
}

/**
 * Substitutes a word based on the Rijndael S-Box.
 *
 * @param w The word to shift
 */
void SubWord(WORD *w)
{
	BYTE b0 = *w & 0x00FF;			//Grab the least significant byte
	BYTE b1 = (*w >> 8) & 0x00FF;	//Grab the second byte
	BYTE b2 = (*w >> 16) & 0x00FF;	//Grab the third byte
	BYTE b3 = (*w >> 24) & 0x00FF;	//Grab the most significant byte

	//combine results - r1 is least significant byte, r4 is most significant byte
	*w = make_word(subByte(b3), subByte(b2), subByte(b1), subByte(b0));
}

/**
 * Substitutes bytes of the current state based on the Rijndael S-box. To save computation, a LUT is
 * implemented. The two hex values of each byte are used to reference a row and coloumn of the
 * Rijndael S-box.
 *
 * @param state Pointer to the current state
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
 * Cicularly left shifts the nth row of the current state by n Bytes. Acts on all rows.
 *
 * @param state Pointer to the current state
 */
void ShiftRows(BYTE *state)
{
	// Shift first row by 1 Byte
	BYTE x1_temp = state[1];
	state[1] = state[5];
	state[5] = state[9];
	state[9] = state[13];
	state[13] = x1_temp;

	// Shift second row by 2 Bytes
	BYTE x2_temp = state[2];
	BYTE x6_temp = state[6];
	state[2] = state[10];
	state[6] = state[14];
	state[10] = x2_temp;
	state[14] = x6_temp;

	// Shift third row by 3 Bytes (or 1 Byte the other way)
	BYTE x15_temp = state[15];
	state[15] = state[11];
	state[11] = state[7];
	state[7] = state[3];
	state[3] = x15_temp;
}

/**
 * Multiplies each column by matrix as shown in GF(2^8) MixColumns performs matrix multiplication
 * with each Word under Rijndael’s finite field. To save computation, a LUT is implementated.
 *
 * @param state Pointer to the current state
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

/**
 * XORs each Byte of the current state with the corresponding Byte from the current RoundKey.
 *
 * @param state The current state of the encryption algorithm.
 * @param round_key The current RoundKey
 */
void AddRoundKey(BYTE* state, WORD* round_key)
{
	int i;
	// For all 16 bytes in State and the current round_key
	for(i = 0; i < (4 * N_COLS); i++)
	{
		// Update state's bytes by XOR-ing with corresponding round_key byte
		state[i] ^= ((round_key[i/4] >> (24 - (8 * (i % 4)))) & 0xFF);
	}
}

/**
 * Generates a RoundKey for every round of the AES encryption process. All of these keys are stored
 * contiguously in the Key Schedule and are based off the previous RoundKey. The first RoundKey is
 * the given Cipher Key.
 *
 * @param key The original Cipher Key
 * @param ks The Key Schedule for storing the RoundKeys
 * @param Nk The number of 32 bit words in the Cipher Key
 */
void KeyExpansion(BYTE *key, WORD *ks, int Nk){
	int i;
	// Assign the key to the first Round Key in key_schedule
	for(i = 0; i < Nk; i++)
	{
		// Since key is just an array of bytes, construct the word from individual bytes
		// and assign it to the respective word in the key_schedule
		ks[i] = make_word(key[4*i], key[4*i+1], key[4*i+2], key[4*i+3]);
	}
	//	for every following word in key_schedule
	for(i = Nk; i < N_COLS*(N_ROUNDS+1); i++)
	{
		// temp will hold the previous word
		WORD temp = ks[i-1];
		// if the current word is the first word of a round key
		if(i % Nk == 0)
		{
			//printf("");
			// run special algorithm for first word of a round key
			RotWord(&temp);
			//printf("After RotWord:  "); print_word(&temp);
			SubWord(&temp);
			//printf("After SubWord:  "); print_word(&temp);
			//printf("Rcon(%02d, :) :   ", i+1); print_word(&(Rcon[(i / Nk)-1]));
			temp ^= Rcon[(i / Nk)-1];
			//printf("After Rcon XOR: "); print_word(&temp); printf("\n");
		}
		// assign the appropriately modified word to the corresponding word in the key_schedule
		ks[i] = ks[i-Nk] ^ temp;
	}
}

/**
 * The AES Encryption Algorithm.
 *
 * @param plaintext The message to be encrypted
 * @param cipher The original Cipher Key
 * @param key_schedule The complete set of 11 RoundKeys
 */
BYTE* AES_Encryption(BYTE* state, BYTE* key, WORD* key_schedule)
{
	//printf("First RoundKey:\n"); print_key_schedule(key_schedule, 0);
	AddRoundKey(state, &key_schedule[0]);

	//printf("State after AddRoundKey:\n"); print_state(state);

	int round;
	for(round = 1; round <= N_ROUNDS-1; round++)
	{
		//printf("State at start of round %d:\n", round); print_state(state);

		SubBytes(state);
		//printf("State after SubBytes:\n"); print_state(state);

		ShiftRows(state);
		//printf("State after ShiftRows:\n"); print_state(state);

		MixColumns(state);
		//printf("State after MixColumns:\n"); print_state(state);

		//printf("RoundKey:\n"); print_key_schedule(key_schedule, round);
		AddRoundKey(state, &key_schedule[round * N_COLS]);
	}
	//printf("State at start of final round:\n"); print_state(state);
	SubBytes(state);
	//printf("State after SubBytes:\n"); print_state(state);
	ShiftRows(state);
	//printf("State after ShiftRows:\n"); print_state(state);
	//printf("RoundKey:\n"); print_key_schedule(key_schedule, N_ROUNDS);
	AddRoundKey(state, &key_schedule[N_ROUNDS * N_COLS]);

	//printf("Final state:\n"); print_state(state);

	return state;
}

int main()
{
	
	// 33 instead of 32 Bytes because of addition of newline character at the end
	BYTE plaintext[33] = 	"ece298dcece298dcece298dcece298dc\n";
	BYTE cipher[33] = 		"000102030405060708090a0b0c0d0e0f\n";

	// Start with pressing reset
	/**to_hw_sig = 0;
	*to_hw_port = 0;
	printf("Press reset!\n");
	while (*to_sw_sig != 3);*/

	clock_t begin = clock();

	int n;
	for(n = 0; n < ITERATIONS; n++)
	{
		int i;
		//*to_hw_sig = 0;
		//printf("\n");

		// Acquire the original message
		//printf("\nEnter message:\n");
		//scanf ("%s", plaintext);
		//printf("\nTransmitting message...\n");

		/*for (i = 0; i < 32; i+=2)
		{
			//printf("Checking byte: %d = %02x\n", i/2, charsToHex(plaintext[i], plaintext[i+1])&0xFF);
			*to_hw_sig = 1;
			*to_hw_port = charsToHex(plaintext[i], plaintext[i+1]);
			while (*to_sw_sig != 1);
			*to_hw_sig = 2;
			while (*to_sw_sig != 0);
		}*/
		//printf ("\n");
		//*to_hw_sig = 0;	// Set HW signal to 0 to exit READ_MSG/MSG_ACK loop

		// Acquire the original key
		//printf("\nEnter cipher:\n");
		//scanf ("%s", cipher);
		//printf("\nTransmitting cipher...\n");
		/*for (i = 0; i < 32; i+=2)
		{
			// printf("Checking byte: %d = %02x\n", i/2, charsToHex(cipher[i], cipher[i+1])&0xFF);
			*to_hw_sig = 2;
			*to_hw_port = charsToHex(cipher[i], cipher[i+1]);
			while (*to_sw_sig != 1);
			*to_hw_sig = 1;
			while (*to_sw_sig != 0);
		}
		//printf ("\n");
		*to_hw_sig = 3;*/	// Set HW signal to 3 to exit READ_KEY/KEY_ACK loop

		// Convert 32 Byte plaintext to condensed 16 Byte state
		BYTE state[4 * N_COLS];
		for(i = 0; i < (4 * N_COLS); i++)
		{
			state[i] = charsToHex(plaintext[2*i], plaintext[2*i+1]);
		}

		//printf("Check Initial State:\n");
		//print_state(state);

		// Convert 32 Byte cipher to condensed 16 Byte key
		BYTE key[4 * N_WORDS_CIPHER];
		for(i = 0; i < (4 * N_WORDS_CIPHER); i++)
		{
			key[i] = charsToHex(cipher[2*i], cipher[2*i+1]);
		}

		//printf("Check Initial Key:\n");
		//print_state(key);

		// Instantiate key_schedule and populate with KeyExpansion
		WORD key_schedule[N_COLS*(N_ROUNDS+1)];
		KeyExpansion(key, key_schedule, N_WORDS_CIPHER);		

		// Call the big Kahuna
		BYTE* encrypted_msg = AES_Encryption(state, key, key_schedule);

		// Display the encrypted message.
		//printf("\nEncrypted message is\n");
		/*for(i = 0; i < 16; i++)
		{
			printf("%02x", encrypted_msg[i] & 0xFF);
		}
		printf("\n");

		printf("\nTransmitting last key...\n");*/
		/*for (i = 0; i < 16; i++)
		{
			*to_hw_sig = 2;
			// printf("%02x", (key_schedule[(N_ROUNDS * N_COLS) + i/4] >> (24 - (8 * (i%4)))) & 0xFF);
			//(ks[(4*index)] >> (24 - (8 * i))) & 0xFF
			*to_hw_port = (key_schedule[(N_ROUNDS * N_COLS) + i/4] >> (24 - (8 * (i%4)))) & 0xFF;
			while (*to_sw_sig != 1);
			*to_hw_sig = 1;
			while (*to_sw_sig != 0);
		}
		//printf ("\n");
		*to_hw_sig = 3;*/	// Set HW signal to 3 to exit READ_KEY/KEY_ACK loop

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
		//while(1);
	}
	clock_t end = clock();
	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	printf("\nRan %d iterations in %.02f seconds.\n", ITERATIONS, time_spent);
	printf("Transmitted %.4f Bytes per second", .0064/time_spent);
	return 0;
}
