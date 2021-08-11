#define _CRT_SECURE_NO_WARNINGS
#include<stdlib.h>
#include<stdio.h>
#include<string.h>

struct ENTRY {
	unsigned int ip;
	unsigned char len;
	unsigned char port;
};

struct list {
	unsigned int port;
	struct list *bitsPointer[16];//from 0000 to 1111 subtrie node
};
typedef struct list node;
typedef node *mtrie;

/*global variables*/
mtrie root;
struct ENTRY *table;
int num_entry = 0;
int num_node = 0;
int stage_node[9] = {0};
int stage_prefix_node[9] ={0};

mtrie create_node() {
	num_node++;
	mtrie temp;
	temp = (mtrie)malloc(sizeof(node));
	//initialize all subnode point to NULL
	for (int i = 0; i < 16; i++)
		temp->bitsPointer[i] = NULL;
	temp->port = 256;//default port number 256 meaning no name
	return temp;
}

void add_node(unsigned int ip, unsigned char len, unsigned char nexthop) {
	mtrie ptr = root;
	unsigned int stridePrefix;//get the wanted 4-bit part of prefix
	for (int i = 0; i < len; i += 4) {
		// if (i+4 > len) mean it is last stride and still not named port
		if ((i + 4 >= len) && (ptr->port == 256)){
			ptr->port = nexthop;
			break;
		}
		stridePrefix = (ip&(0xF0000000 >> i)) >> (28 - i);
		if (ptr->bitsPointer[stridePrefix] == NULL) {
			for(int j =0;j<16;j++)
				ptr->bitsPointer[j] = create_node();
		}
		ptr = ptr->bitsPointer[stridePrefix];
	}
}

void read_table(char *str, unsigned int *ip, int *len, unsigned int *nexthop) {
	char tok[] = "./";
	char buf[100], *str1;
	unsigned int n[4];

	sprintf(buf, "%s\0", strtok(str, tok));
	n[0] = atoi(buf);
	sprintf(buf, "%s\0", strtok(NULL, tok));
	n[1] = atoi(buf);
	sprintf(buf, "%s\0", strtok(NULL, tok));
	n[2] = atoi(buf);
	sprintf(buf, "%s\0", strtok(NULL, tok));
	n[3] = atoi(buf);

	*nexthop = n[2];
	str1 = (char *)strtok(NULL, tok);

	if (str1 != NULL) {
		sprintf(buf, "%s\0", str1);
		*len = atoi(buf);
	}
	else {
		if (n[1] == 0 && n[2] == 0 && n[3] == 0)
			*len = 8;
		else
			if (n[2] == 0 && n[3] == 0)
				*len = 16;
			else
				if (n[3] == 0)
					*len = 24;
	}

	*ip = n[0];
	*ip <<= 8;
	*ip += n[1];
	*ip <<= 8;
	*ip += n[2];
	*ip <<= 8;
	*ip += n[3];
}

void set_table(char *file_name) {
	FILE *fp;
	int len;
	char string[100];
	unsigned int ip, nexthop;
	fp = fopen(file_name, "r");
	while (fgets(string, 50, fp) != NULL) {
		read_table(string, &ip, &len, &nexthop);
		num_entry++;
	}
	rewind(fp);
	table = (struct ENTRY *)malloc(num_entry * sizeof(struct ENTRY));
	num_entry = 0;
	while (fgets(string, 50, fp) != NULL) {
		read_table(string, &ip, &len, &nexthop);
		table[num_entry].ip = ip;
		table[num_entry].port = nexthop;
		table[num_entry++].len = len;
	}
}

void create() {
	int i;
	root = create_node();
	for (i = 0; i < num_entry; i++)
		add_node(table[i].ip, table[i].len, table[i].port);
}

void count_stage_node(mtrie b,int stage){	
	if(b == NULL)
		return;
	for(int i =0;i<16;i++)
		count_stage_node(b->bitsPointer[i],stage+1);

	stage_node[stage]++;
	if(b->port != 256)
		stage_prefix_node[stage+1]++;
 
}

int main(int argc, char *argv[]) {
	int i, j;
	set_table(argv[1]);
	create();
	printf("number of nodes: %d\n", num_node);
	count_stage_node(root, 0);

	for(i=0;i<9;i++)
		printf("# of nodes with stage %d: %d nodes\n",i,stage_node[i]);

	for(i=0;i<9;i++)
		printf("# of prefix nodes with stage %d: %d nodes\n",i,stage_prefix_node[i]);	


	return 0;
}
