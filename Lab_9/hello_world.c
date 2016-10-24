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

#define to_hw_port (volatile char*) 0x00000050
#define to_hw_sig (volatile char*) 	0x00000040
#define to_sw_port (char*) 			0x00000030
#define to_sw_sig (char*) 			0x00000020

// Copied from aes.c (Jacob)
#define byte unsigned char // 8-bit byte
#define word unsigned long // 32-bit word

#define N_ROUNDS 10		// self-defined constant (Jacob)
#define N_COLS   4 		// self-defined constant (Jacob)

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
void KeyExpansion(byte cipher[33], word w[N_COLS])
{
	word wtemp;
	for(int i; i < (N_ROUNDS*N_COLS); i++){			//	for every Word wi in all n RoundKeys (i=1,2,…,4n, n=10){
		wtemp = w[i-1];								//		wtemp = wi-1
		if(w[i] % N_COLS == 0)						//		if wi is the first Word in the current RoundKey
			wtemp = SubBytes(RotWord(wtemp)) ^ Rconn;//			wtemp = SubWord(RotWord(wtemp)) xor Rconn
		for(int i; i < N_COLS; i++){				//	for every Word in the current RoundKey, including the first Word
			w[i] = w[i-4] ^ wtemp;					//		wi = wi-4 xor wtemp
		}
	}
}

/**
 * SubWord
 * Same as SubBytes()
 */
void SubBytes(word *w)
{


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

MixColumns(byte state)
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

		// TODO: Key Expansion and AES encryption using week 1's AES algorithm.
		// AES(byte plaintext[4*N_COLS], byte cipher[4*N_COLS], word w[N_COLS*(N_ROUNDS+1)])
		// Nr = N_ROUNDS = 10, Nb = N_COLS = 4, in = plaintext, out = cipher, w = Cipher Key
		byte state[4][N_COLS];
		state = plaintext;
		AddRoundKey(state, w[0, N_COLS-1]);
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

