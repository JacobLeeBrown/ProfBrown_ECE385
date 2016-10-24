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

#define N_ROUNDS 	10		// self-defined constant (Jacob)
#define N_COLS   	4 		// self-defined constant (Jacob)
#define N_WORDS		4		// self-defined constant (Jacob)

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

// TODO: AES Encryption related function calls

/**
 * AddRoundKey
 * XORs each Byte with the corresponding Byte from the current RoundKey
 * – Each Round of the algorithm uses different RoundKeys
 * – Each RoundKey is generated from the previous RoundKey
 * – RoundKeys can be generated either altogether at the beginning of the AES algorithm,
 *   or during each round
 */
void AddRoundKey(byte state[4][N_COLS], word w[N_COLS])
{


}

/**
 * KeyExpansion
 * Generates a RoundKey at a time based on the previous RoundKey (use the Cipher Key
 * to generate the first RoundKey)
 * – RotWord() – circularly shift each Byte in a Word up by 1 Byte
 * – SubWord() – identical to SubBytes()
 * – Rcon() – xor the Word with the corresponding Word from the Rcon lookup table
 */
void KeyExpansion(byte key[33], word w[N_COLS*(N_ROUNDS+1)], N_WORDS){
	word wtemp;
	int i;
	// Assign the key to the first Round Key in key_schedule
	for(i = 0; i < N_WORDS; i++)
	{
		// Since key is just an array of bytes, construct the word from individual bytes 
		// and assign it to the respective word in the key_schedule
		w[i] = word(key[4*i], key[4*i+1], key[4*i+2], key[4*i+3]);
	}
	//	for every following word in key_schedule
	for(i = N_WORDS; i < N_COLS*(N_ROUNDS+1); i++)
	{
		// temp will hold the previous word
		word wtemp = w[i-1];
		// if the current word is the first word of a round key
		if(i % N_WORDS == 0)
		{
			// run special algorithm for first word of a round key
			wtemp = SubWord(RotWord(wtemp)) ^ Rconn[i / N_WORDS];
		}
		// assign the appropriately modified word to the corresponding word in the key_schedule
		w[i] = w[i-1] ^ wtemp;
	}
}

/**
 * SubWord
 * Same as SubBytes(), but acts only on a single word at a time
 */
void SubWord(word *w)
{
	byte b1 = *w & 0x00FF;			//Grab the least significant byte
	byte b2 = (*w >> 8) & 0x00FF;	//Grab the second byte
	byte b3 = (*w >> 16) & 0x00FF;	//Grab the third byte
	byte b4 = (*w >> 24) & 0x00FF;	//Grab the most significant byte

	//break each byte into 2 nibbles
	byte b1_L = b1 & 0x000F;
	byte b1_M = (b1 >> 4) & 0x000F;
	byte b2_L = b2 & 0x000F;
	byte b2_M = (b2 >> 4) & 0x000F;
	byte b3_L = b3 & 0x000F;
	byte b3_M = (b3 >> 4) & 0x000F;
	byte b4_L = b4 & 0x000F;
	byte b4_M = (b4 >> 4) & 0x000F;

	//get results - "first nibble in the first index (row),
	//				 second nibble in the second index (column)"
	byte r1 = aes_sbox[b1_M][b1_L];
	byte r2 = aes_sbox[b2_M][b2_L];
	byte r3 = aes_sbox[b3_M][b3_L];
	byte r4 = aes_sbox[b4_M][b4_L];

	//combine results - r1 is least significant byte, r4 is most significant byte
	*w = (r4 << 24) | (r3 << 16) | (r2 << 8) | (r1);
}

/**
 * RotWord
 * Rotates 4-Byte word left
 */
void RotWord(word *w)
{
	word temp = 0x00000000;		//Create an empty 4-byte temp variable
	temp = *w & 0xFF000000;		//Bit-mask first byte of word w and store in temp
	temp >>= 24;				//Shift temp right by 3 bytes
	*w <<= 8;					//Shift word w by 1 byte
	*w |= temp;					//Logical OR such that word w now has the first byte
								//moved to the last byte
}

void MixColumns(byte state[4*N_COLS])
{

}

int main()
{
	int i;
	unsigned char plaintext[33]; //should be 1 more character to account for string terminator
	unsigned char key[33];
	unsigned char cipher[33];

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

		word key_schedule[N_COLS*(N_ROUNDS+1)];

		// TODO: Key Expansion and AES encryption using week 1's AES algorithm.
		// AES(byte plaintext[4*N_COLS], byte cipher[4*N_COLS], word w[N_COLS*(N_ROUNDS+1)])
		// Nr = N_ROUNDS = 10, Nb = N_COLS = 4, in = plaintext, out = cipher, w = Cipher Key
		byte state[4 * N_COLS];
		state = plaintext;
		AddRoundKey(state, key_schedule, 0);
		int round;
		for(round = 1; round <= N_ROUNDS-1; round++)
		{
			SubBytes(state);
			ShiftRows(state);
			MixColumns(state);
			AddRoundKey(state, w[round * N_COLS, (round + 1) * N_COLS - 1]);
		}
		SubBytes(state);
		ShiftRows(state);
		AddRoundKey(state, w[N_ROUNDS * N_COLS, (N_ROUNDS + 1) * N_COLS - 1]);
		cipher = state + "\n";


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

