#define _CRT_SECURE_NO_WARNINGS
#include<stdlib.h>
#include<stdio.h>
#include<string.h>

#define READ_STR_BUF 100

struct ENTRY{
	unsigned int ip; 
	unsigned char len;
	unsigned int port;
};

struct list{
	unsigned int layer;
	unsigned int port;
	struct list *left,*right;
};
typedef struct list node;
typedef node *btrie;

/*global variables*/
btrie root;
struct ENTRY *table;
int num_entry = 0;
int num_node = 0;
int prefix_node = 0;
int layer_node[15] = {0};
int level_node[32] = {0};

btrie create_node(){
	btrie temp;
	temp=(btrie)malloc(sizeof(node));
	temp->right=NULL;
	temp->left=NULL;
	temp->port=256;//default port is 8'b00000000
	return temp;
}

void add_node(unsigned int ip,unsigned char len,unsigned char nexthop){
	btrie ptr=root;
	int i;
	for(i=0;i<len;i++){
		// which bit from head, 1 mean right node 0 mean left node
		if(ip&(1<<(31-i))){
			// child is NULL
			if(ptr->right==NULL)
				ptr->right=create_node(); 
			ptr=ptr->right;
			// leaf node
			if((i==len-1)&&(ptr->port==256))
				ptr->port=nexthop;
		}
		else{
			if(ptr->left==NULL)
				ptr->left=create_node();
			ptr=ptr->left;
			if((i==len-1)&&(ptr->port==256))
				ptr->port=nexthop;
		}
	}
}

//Split one line and reassembly for ip format
void read_table(char *str,unsigned int *ip,int *len,unsigned int *nexthop){
	char tok[]="./";
	char buf[READ_STR_BUF],*str1;
	unsigned int n[4];//store ip value
	sprintf(buf,"%s\0",strtok(str,tok));
	n[0]=atoi(buf);
	sprintf(buf,"%s\0",strtok(NULL,tok));
	n[1]=atoi(buf);
	sprintf(buf,"%s\0",strtok(NULL,tok));
	n[2]=atoi(buf);
	sprintf(buf,"%s\0",strtok(NULL,tok));
	n[3]=atoi(buf);
	*nexthop=n[2];//nexthop = n[2] just mean random nexthop value
	//deal with prefix length
	str1=(char *)strtok(NULL,tok);
	if(str1!=NULL){
		sprintf(buf,"%s\0",str1);
		*len=atoi(buf);
	}
	else{//exception situation
		if(n[1]==0&&n[2]==0&&n[3]==0)
			*len=8;
		else
			if(n[2]==0&&n[3]==0)
				*len=16;
			else
				if(n[3]==0)
					*len=24;
	}
	//assign to ip with correct format
	*ip=n[0];
	*ip<<=8;
	*ip+=n[1];
	*ip<<=8;
	*ip+=n[2];
	*ip<<=8;
	*ip+=n[3];
}

void set_table(char *file_name){
	FILE *fp;
	int len;
	char string[READ_STR_BUF];
	unsigned int ip, nexthop;
	fp=fopen(file_name,"r");
	//count wanted table size
	while(fgets(string,READ_STR_BUF-1,fp)!=NULL){
		read_table(string, &ip, &len, &nexthop);
		num_entry++;
	}
	rewind(fp);
	//allocate table space
	table=(struct ENTRY *)malloc(num_entry*sizeof(struct ENTRY));
	num_entry=0;
	//get table info
	while(fgets(string,READ_STR_BUF-1,fp)!=NULL){
		read_table(string,&ip,&len,&nexthop);
		table[num_entry].ip=ip;
		table[num_entry].port=nexthop;
		table[num_entry++].len=len;
	}
}

//Create binary trie structure
void create(){
	int i;
	root = create_node();
	for (i = 0; i < num_entry; i++)
		add_node(table[i].ip, table[i].len, table[i].port);
}

//Count trie node with inorder
void count_node(btrie r, int level){
	if(r==NULL)
		return;
	count_node(r->left,level+1);
	num_node++;
	level_node[level]++;
	if(r->port != 256)
		prefix_node++;
	count_node(r->right,level+1);
}

//Set trie node's layer for count
int set_layer(btrie r){
	if(r==NULL)
		return -1;

	int left_layer, right_layer;
	left_layer = set_layer(r->left);
	right_layer = set_layer(r->right);

	if(r->port != 256){
		if(left_layer < right_layer)
			r->layer = left_layer + 1;
		else
			r->layer = right_layer + 1;
	}
	else{
		if(left_layer < right_layer)
			r->layer = left_layer;
		else
			r->layer = right_layer;
	}

	return r->layer;
}
// Count # of trie's layer node
void count_layer_node(btrie r){
	if(r==NULL)
		return;
	count_layer_node(r->left);
	count_layer_node(r->right);

	if(r->port != 256){
		layer_node[r->layer]++;
	}
}

int main(int argc,char *argv[]){
	int i,j;//index variable
	set_table(argv[1]);

	create();//build binary trie
    
	count_node(root,0);
	printf("number of nodes created in binary trie: %d\n",num_node);
	printf("# of nodes have nexthop:%d\n",prefix_node);

	for(i=0;i<32;i++)
		printf("# of level %d nodes: %d nodes\n",i,level_node[i]);

	// count about layer
	set_layer(root);
	count_layer_node(root);

	for(i=0;i<15;i++)
		printf("layer %d: %d nodes\n",i,layer_node[i]);

	return 0;
}
