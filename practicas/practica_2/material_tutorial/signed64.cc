#include <iostream>

// 2147483647 + 2147483647 = 4294967294
// 0x7fffffff + 0x7fffffff = 0xfffffffe

int lista[] = {0x7fffffff, 0x7fffffff};
unsigned n = sizeof(lista) / sizeof(int);

long long suma1(int *lista, unsigned longlista)
{
	long long total = 0;
	for (unsigned i = 0; i < longlista; ++i)
		total += lista[i];
	return total;
}

long long suma2(int *begin, int* end)
{
	long long total = 0;
	while (begin != end)
		total += *begin++;
	return total;
}

int main()
{
	long long s1 = suma1(lista, n),
	          s2 = suma2(lista, lista + n);
	
	std::cout << "suma1 = " << std::dec << s1 
	          << " / 0x" << std::hex << s1 << std::endl
	          << "suma2 = " << std::dec << s2 
	          << " / 0x" << std::hex << s2 << std::endl;
}
