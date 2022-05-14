@** Aho-Corasick algorithm.
This document is about Aho-Corasick algorithm's implementation and some applications
in code competition, for simplicity, does not involve the design of algorithm~[1].
We first go through some building blocks for a typical string matching program, including
alphabet~[2], trie~[3],  and KMP algorithm~[4], then I show a straightforward implementation
of Aho-Corasick algorithm.  The implementation does some simple string matching works that
the algorithm originally designed for.  At last, I show some sample solutions
for selected code competation problems on POJ(www.poj.org).  The rest of this chapter is devoted to
the buiding blocks.

The building blocks are shared by all sample programs.
@<the common part of sample programs@>=
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
@<data(common part)@>@/
@<functions(common part)@>@/

@ Alphabet here only maps ASCII to inner orders, does not concern unicode.  It may
seem weird because both sizes of domain are |UCHAR_MAX|, but it's enough for our purpose.
And, only one instance of alphabet is needed.
@<data(common part)@>=
unsigned char ord[UCHAR_MAX+1];
unsigned char chr[UCHAR_MAX+1];

@ The size of alphabet can be computed by counting non-zeros.
@<functions(common part)@>=
size_t alphabet_size()
{ int i; size_t s = 0;
	for (i = 1; chr[i]; i++) {
		s++;
	}
	return s;
}

@ I use a relatively simple design of trie but with a little extension that to record every node
with a number to identify it.
@<data(common part)@>=
#define MAX_NODE 10000 /* the max number of node */
#define NODE(n) (trie_nodes[(n)])
typedef struct trie_node{
	int v; /* the value of node */
	int n; /* the number of node */
	unsigned char c; 
	struct trie_node **tbl;
} trie_node;
size_t n_node; /* the amount of node */
trie_node *trie_nodes[MAX_NODE]; /* index node by n */

@ @<functions(common part)@>=
trie_node *new_trie_node()
{ static size_t as; trie_node *p;
	if (!as) as = alphabet_size()+1;
	p = (trie_node *) calloc(1, sizeof(trie_node));
	p->n = n_node++;
	trie_nodes[p->n] = p;
	p->tbl = (trie_node **) calloc(as, sizeof(trie_node **));
	return p;
}

@ Trie is implemented partly, for example, in most cases, we don't need to delete entries from table.
I also record each node's parent node to follow the original design of KMP algorithm.
@<data(common part)@>=
size_t p_node[MAX_NODE];

@ |search_entry| is the only function we need.
@<functions(common part)@>=
trie_node *search_entry(trie_node *root, unsigned char *str)
{ unsigned char o = ord[str[0]];
	if (o == 0) {
		return root;
	}
	if (root->tbl[o] == NULL) { trie_node *nn;
		nn = new_trie_node();
		root->tbl[o] = nn;
		nn->c = o;
		p_node[nn->n] = root->n;
	}
	return search_entry(root->tbl[o], str+1);
}

@ KMP on trie does not differ much from on sequence.  Adopting the notations from [4], let's
start with the function that calculate $\delta$ from $\pi$.
@<data(common part)@>=
size_t prefix[MAX_NODE]; /* the $\pi$ */

@ @<functions(common part)@>=
size_t KMP_goto(size_t nd, unsigned char c)
{ size_t nd_t, nd_tt;
	nd_t = nd;
	do {
		if (NODE(nd_t)->tbl[c]) {
			return NODE(nd_t)->tbl[c]->n;
		}
		nd_tt = nd_t;
		nd_t = prefix[nd_t];
	} while (nd_t != nd_tt);
	return 0;
}

@ Then the generating of |prefix| can be easily done.
@<functions(common part)@>=
void KMP_prefix()
{ int i;
	for (i = 1; i < n_node; i++) {
		if (p_node[i] == 0) continue;
		prefix[i] = KMP_goto(prefix[p_node[i]], NODE(i)->c);
	}
}

@* A straightforward implementation.
Having all these building blocks, we can give an simple text matching program now.
This simple text matching program accept a list of command line arguments as keywords,
and match standard input for these keywords.

@c
@<the common part of sample programs@>@/

int main(int argc, char *argv[])
{ trie_node *root; int i, m;
	for (i = 0; i < CHAR_MAX; i++) {
		ord[i] = (unsigned char) i, chr[i] = (unsigned char) i; /* an identical mapping */
	}
	root = new_trie_node();
	for (i = 1; i < argc; i++) { trie_node *nd;
		nd = search_entry(root, argv[i]);
		nd->v = 1;
	}
	KMP_prefix();
	@<record the times matched as |m|@>@;
	printf("totally matched %d times\n", m);
}

@ @<record the times...@>=
{ char c; size_t s;
	m = 0;
	s = 0;
	while ((c = getchar()) != EOF) {
		s = KMP_goto(s, ord[(unsigned char)c]);
		if (NODE(s)->v) m++;
	}
}

@* POJ 1625.

Description:
\midinsert
\narrower \narrower
\noindent\llap{``}
The alphabet of Freeland consists of exactly $N$ letters. Each sentence of Freeland language
(also known as Freish) consists of exactly $M$ letters without word breaks. So, there exist
exactly $N^M$ different Freish sentences.  But after recent election of Mr. Grass Jr. as
Freeland president some words offending him were declared unprintable and all sentences
containing at least one of them were forbidden. The sentence $S$ contains a word $W$ if $W$ is
a substring of $S$ i.e. exists such $k \ge 1$ that $S[k] = W[1]$, $S[k+1] = W[2]$, $\ldots$, $S[k+len(W)-1] = W[len(W)]$,
where $k+len(W)-1 \le M$ and $len(W)$ denotes length of $W$. Everyone who uses a forbidden sentence is to be put to jail for 10 years.
Find out how many different sentences can be used now by freelanders without risk to be put to jail for using it.

The first line of the input file contains three integer numbers: $N$---the number of letters in Freish alphabet,
$M$---the length of all Freish sentences and $P$---the number of forbidden words ($1 \le N \le 50$, $1 \le M \le 50$, $0 \le P \le 10$).
The second line contains exactly $N$ different characters---the letters of the Freish alphabet (all with ASCII code greater than 32).
The following $P$ lines contain forbidden words, each not longer than $min(M, 10)$ characters, all containing only letters of Freish alphabet.''
\endinsert
@(poj1625.c@>=
@<the common part of sample programs@>@/
@<data(poj1625)@>@/
@<functions(poj1625)@>@/

int main()
{ int N, M, P; trie_node *root;
	scanf("%d %d %d\n", &N, &M, &P);
	@<build alphabet(poj1625)@>@;
	@<build trie(poj1625)@>@;
	KMP_prefix();
	@<compute output(poj1625)@>@;
}

@ @<build alphabet(poj1625)@>=
{ unsigned char c, o;
	o = 1;
	while ((c = getchar()) != '\n') {
		ord[c] = o, chr[o] = c;
		o++;
	}
}

@ @<build trie(poj1625)@>=
{ int i; unsigned char w[51];
	root = new_trie_node();
	for (i = 0; i < P; i++) { trie_node *nd;
		fgets(w, 50, stdin);
		if (w[strlen(w)-1] == '\n') w[strlen(w)-1] = '\0';
		nd = search_entry(root, w);
		nd->v = 1;
	}
}

@ Consider the finit state machine we have built, all safe sentences are the ones that do not go through the particular states.
Then the solution is clear, we can denote the number of safe sentences of length $l$ ended by state $s$ by $D(l, s)$,
and $p(s)$ to say state $s$ is safe, if $p(s)$ we have
$$
D(l+1, s) = \sum_{\delta(S, c)=s}D(l, S) = \sum_{\delta(S, c)=s}\sum_cD(l,S) = \sum_{\delta(S, c)=s}n(c)D(l, S),
$$
else we have
$$
D(l+1, s) = 0,
$$
the final answer is $A = \sum D(M, s)$, as we all know, this type of problem can be solved by dynamic programming.
But before we go forward, we should give ``safe'' a definition.  Let's consider two words, ``bca'' and ``c'',
no doubt that ``bcb'' is not a safe sentence because of ``c'', but we can not explore this information in our |KMP_goto|,
since we always reserve prefixes as long as possible.  So we should devise some extension based on |KMP_goto|.
@<functions(poj1625)@>=
int is_safe(size_t nd)
{
	static int mem[600];
	if (mem[nd]) {
		return mem[nd]-1;
	}
	if (NODE(nd)->v) {
		mem[nd] = 1;
		return 0;
	}
	{ size_t nd_t, nd_tt;
		nd_t = p_node[nd];
		do { trie_node *np = NODE(nd_t)->tbl[NODE(nd)->c];
			if (np) {
				if (!is_safe(nd_t)) {
					mem[nd] = 1;
					break;
				}
				if (np != trie_nodes[nd] && !is_safe(np->n)) {
					mem[nd] = 1;
					break;
				}
			}
			nd_tt = nd_t;
			nd_t = prefix[nd_t];
		} while (nd_t != nd_tt);
	}
	if (!mem[nd]) mem[nd] = 2;
	return mem[nd]-1;
}

@ To save time, I save $\delta(S, c) = s$ to a table.
@<data(poj1625)@>=
#define RNODE_V(n) (rnodes[n][0])
#define RNODE_N(n) (rnodes[n][1])
#define RNODE_T(n) (rnodes[n][2])
int route[600];
int rnodes[600*600][3];
int n_rnode = 1;

@ @<compute output(poj1625)@>=
{ int i, j;
	for (i = 0; i < n_node; i++) {
		if (!is_safe(i)) continue;
		for (j = 1; j <= N; j++) {
			int t = KMP_goto(i, j);
			@<insert new node to |rnodes|@>@;
		}
	}
}

@ @<insert new node to |rnodes|@>=
{ int rnd = route[t];
	if (rnd == 0) {
		RNODE_T(n_rnode) = i;
		RNODE_V(n_rnode) = 1;
		route[t] = n_rnode++;
		continue;
	}
	while (RNODE_N(rnd) && RNODE_T(rnd)!=i) rnd = RNODE_N(rnd);
	if (RNODE_T(rnd) == i) {
		RNODE_V(rnd)++;
	} else {
		RNODE_T(n_rnode) = i;
		RNODE_V(n_rnode) = 1;
		RNODE_N(rnd) = n_rnode++;
	}
}

@ Because the final answer may be as large as ${50}^{50}$, we should use big numbers.
@<data(poj1625)@>=
#define CELL 10000
typedef struct {
	int arr[25];
	int l;
} bignum;

bignum D[51][600];
bignum A;

@ @<functions(poj1625)@>=
void bignum_add(bignum *t, bignum *a)
{ int i, l;
	if (a->l == 0) return;
	l = t->l>a->l ? t->l : a->l;
	for (i = 0; i < l; i++) {
		t->arr[i] += a->arr[i];
		t->arr[i+1] += t->arr[i]/CELL;
		t->arr[i] %= CELL;
	}
	if (t->arr[l]) t->l = l+1;
	else t->l = l;
}

void bignum_scale(bignum *t, int m)
{ int i;
	if (t->l == 0) return;
	for (i = 0; i < t->l; i++) {
		t->arr[i] *= m;
	}
	for (i = 0; i < t->l; i++) {
		t->arr[i+1] += t->arr[i]/CELL;
		t->arr[i] %= CELL;
	}
	if (t->arr[t->l]) t->l++;
}

void print_bignum(bignum *bn)
{ int i;
	if (bn->l == 0) {
		printf("0");
		return;
	}
	printf("%d", bn->arr[bn->l-1]);
	for (i = bn->l-2; i >= 0; i--) {
		printf("%04d", bn->arr[i]);
	}
	printf("\n");
}

@ @<compute output(poj1625)@>=
{ int i, j;
	D[0][0].arr[0] = 1;
	D[0][0].l = 1;

	for (i = 1; i <= M; i++) {
		for (j = 0; j < n_node; j++) {
			@<compute |D[i][j]|(poj1625)@>@;
		}
	}
	for (i = 0; i < n_node; i++) {
		bignum_add(&A, &D[M][i]);
	}
	print_bignum(&A);
}

@ @<compute |D[i][j]|(poj1625)@>=
{ int rnd;
	if (!is_safe(j)) continue;
	rnd = route[j];
	while (rnd) { static bignum bn;
		int t = RNODE_T(rnd);
		bn = D[i-1][t];
		bignum_scale(&bn, RNODE_V(rnd));
		bignum_add(&D[i][j], &bn);
		rnd = RNODE_N(rnd);
	}
}

@* References.

[1] Alfred V. Aho and Margaret J. Corasick, {\sl Efficient String Matching}, {\bf 1975}.\par
[2] Robert Sedgewick, Kevin Wayne, {\sl Algorithms}, 5, {\bf 2011}.\par
[3] Robert Sedgewick, Kevin Wayne, {\sl Algorithms}, 5--2, {\bf 2011}.\par
[4] Charles E. Leiserson, Ronald L. Rivest, Clifford Stein, {\sl An introduction to Algorithms}, 32, {\bf 2009}.\par
