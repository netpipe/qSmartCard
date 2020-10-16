int ascHexToInt(char aChar ){
	switch(toupper(aChar)){
		case 48: //0
			return 0;
			break;
		case 49: //1
			return 1;
			break;
		case 50: //2
			return 2;
			break;
		case 51: //3
			return 3;
			break;
		case 52: //4
			return 4;
			break;
		case 53: //5
			return 5;
			break;
		case 54: //6
			return 6;
			break;
		case 55: //7
			return 7;
			break;
		case 56: //8
			return 8;
			break;
		case 57: //9
			return 9;
			break;
		case 65: //A
			return 10;
			break;
		case 66: //B
			return 11;
			break;
		case 67: //C
			return 12;
			break;
		case 68: //D
			return 13;
			break;
		case 69: //E
			return 14;
			break;
		case 70: //F
			return 15;
			break;
		default:
			return 0;
	}
	return 0;
}

char intToAscHex(int aInt ){
	switch(aInt){
		case 0: //0
			return '0';
			break;
		case 1: //1
			return '1';
			break;
		case 2: //2
			return '2';
			break;
		case 3: //3
			return '3';
			break;
		case 4: //4
			return '4';
			break;
		case 5: //5
			return '5';
			break;
		case 6: //6
			return '6';
			break;
		case 7: //7
			return '7';
			break;
		case 8: //8
			return '8';
			break;
		case 9: //9
			return '9';
			break;
		case 10: //A
			return 'A';
			break;
		case 11: //B
			return 'B';
			break;
		case 12: //C
			return 'C';
			break;
		case 13: //D
			return 'D';
			break;
		case 14: //E
			return 'E';
			break;
		case 15: //F
			return 'F';
			break;
		default:
			return '0';
	}
	return '0';
}
