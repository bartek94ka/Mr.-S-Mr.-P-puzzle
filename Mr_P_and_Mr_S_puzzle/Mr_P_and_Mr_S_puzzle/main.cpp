#include <stdio.h>
#include <stdlib.h>

#define	_MinNum         2
#define	_MaxNum         1000

#define	_MinSum         (2 * _MinNum)
#define	_MaxSum         (2 * _MaxNum)
#define	_MinPrd         (_MinNum * _MinNum)
#define	_MaxPrd         (_MaxNum * _MaxNum)
#define _PrdSpc         (_MaxPrd - _MinPrd + 1)
#define _SumSpc         (_MaxSum - _MinSum + 1)

#define	LongNum	        unsigned long
#define ShortNum        unsigned int
#define	Byte            unsigned char
#define	Boolean	        unsigned char
#define	True            1
#define	False	        0

typedef struct
{
	ShortNum              FstNum, LstNum, Step;
	ShortNum              MinSum, MaxSum, SumSpc;
	LongNum               MinPrd, MaxPrd, PrdSpc;
} _InpDat;

typedef struct PrdTabFact
{
	LongNum               Fact1;
	LongNum               Fact2;
	struct                PrdTabFact *Next;
} _PrdTabFact;

typedef struct
{
	Boolean               Flg;
	ShortNum              Num;
	struct PrdTabFact     *FactsPtr;
} _PrdTabElem;

typedef struct
{
	LongNum               Fact1;
	LongNum               Fact2;
	ShortNum              Num;
} _OutDat;
/*
Elementy PrdTab reprezentuj¹ wszystkie mo¿liwe
numery produktów nale¿¹ce do danych wejœciowych.
Ka¿dy element w strukturze zawiera pola:
-Flg - flaga wskazuj¹ca czy podany produkt spe³nia podane warunki
-Num - liczba mo¿liwych rozk³adów produktu
-FactsPtr - wskaŸnik do listy zdekomponownych/roz³o¿onych produktów
(lista par elementów/liczb)
*/
typedef _PrdTabElem     _PrdTab[_PrdSpc];
/*
SumTab reprezentuje wszystkie mo¿liwe sumy analizowanych par liczb.
Ka¿dy element posiada:
-flagê : czy suma spe³nia podane warunki
Wartoœæ sumy jest reprezentowana przez wartoœæ z danego indeksu
*/
typedef Boolean         _SumTab[_SumSpc];

_InpDat                 *InpDat;
_PrdTab                 PrdTab;
_SumTab                 SumTab;

void InputData(_InpDat *InpDat);
void InitPrdTab(_InpDat *InpDat, _PrdTab PrdTab);
void InitSumTab(_InpDat *InpDat, _SumTab SumTab);
void MrS1(_InpDat *InpDat, _PrdTab PrdTab, _SumTab SumTab);
void MrP1(_InpDat *InpDat, _PrdTab PrdTab, _SumTab SumTab);
void MrS2(_InpDat *InpDat, _PrdTab PrdTab, _SumTab SumTab, _OutDat *OutDat);
void PrnRes(_OutDat *OutDat);

//wczytanie danych ze streama i obliczenie wszystkich danych wejœciowych
void InputData(_InpDat *InpDat)
{
	printf("\nEnter FirstNumber, LastNumber, Step >");
	scanf("%d,%d,%d", &InpDat->FstNum, &InpDat->LstNum, &InpDat->Step);
	InpDat->MinSum = 2 * InpDat->FstNum;
	InpDat->MaxSum = 2 * InpDat->LstNum;
	InpDat->SumSpc = InpDat->MaxSum - InpDat->MinSum + 1;
	InpDat->MinPrd = InpDat->FstNum * InpDat->FstNum;
	InpDat->MaxPrd = InpDat->LstNum * InpDat->LstNum;
	InpDat->PrdSpc = InpDat->MaxPrd - InpDat->MinPrd + 1;
}

void InitPrdTab(_InpDat *InpDat, _PrdTab PrdTab)
{
	LongNum i, j, PrdTabInd;
	ShortNum FstNum = InpDat->FstNum;
	ShortNum LstNum = InpDat->LstNum;
	ShortNum Step = InpDat->Step;
	LongNum  PrdSpc = InpDat->PrdSpc;
	LongNum  MinPrd = InpDat->MinPrd;

	for (i = 0; i < PrdSpc; i++)
	{
		PrdTab[i].Flg = False;
		PrdTab[i].Num = 0;
		PrdTab[i].FactsPtr = NULL;
	}
	for (i = FstNum; i <= LstNum; i += Step)
		for (j = i; j <= LstNum; j += Step)
		{
			_PrdTabFact *PrdTabFact;

			PrdTabFact = (_PrdTabFact *)malloc(sizeof(_PrdTabFact));
			PrdTabFact->Fact1 = i;
			PrdTabFact->Fact2 = j;

			PrdTabInd = (i * j) - MinPrd;

			PrdTab[PrdTabInd].Flg = True;
			++PrdTab[PrdTabInd].Num;
			PrdTabFact->Next = PrdTab[PrdTabInd].FactsPtr;
			PrdTab[PrdTabInd].FactsPtr = PrdTabFact;
		}
}

void InitSumTab(_InpDat *InpDat, _SumTab SumTab)
{
	LongNum i, j;
	ShortNum FstNum = InpDat->FstNum;
	ShortNum LstNum = InpDat->LstNum;
	ShortNum Step = InpDat->Step;
	ShortNum MinSum = InpDat->MinSum;

	for (i = 0; i <= 1; i++)
		SumTab[i] = False;
	for (i = FstNum; i <= LstNum; i += Step)
		for (j = i; j <= LstNum; j += Step)
			SumTab[i + j - MinSum] = True;
}

void MrS1(_InpDat *InpDat, _PrdTab PrdTab, _SumTab SumTab)
{
	LongNum i;
	ShortNum Step = InpDat->Step;
	ShortNum MinSum = InpDat->MinSum;
	ShortNum MaxSum = InpDat->MaxSum;
	LongNum  MinPrd = InpDat->MinPrd;

	for (i = MinSum + 2; i <= MaxSum; i++)
	{
		LongNum Fact1 = InpDat->FstNum;
		LongNum Fact2;
		LongNum Prd;

		do
		{
			Fact2 = i - Fact1;
			Prd = (Fact1 * Fact2) - MinPrd;
			Fact1 += Step;
		} while ((Fact1 <= i / 2) && (PrdTab[Prd].Num > 1));
		if (PrdTab[Prd].Num <= 1)
			SumTab[i - MinSum] = False;
	}
}

void MrP1(_InpDat *InpDat, _PrdTab PrdTab, _SumTab SumTab)
{
	LongNum i;
	LongNum  PrdSpc = InpDat->PrdSpc;
	ShortNum MinSum = InpDat->MinSum;

	for (i = 0; i < PrdSpc; i++)
		if (PrdTab[i].Flg && (PrdTab[i].Num > 1))
		{
			int j;
			int OKSumCntr = 0;
			_PrdTabFact  *PrdTabFact = PrdTab[i].FactsPtr;

			for (j = 1; j <= PrdTab[i].Num; j++)
			{
				LongNum  SumTabInd = PrdTabFact->Fact1 + PrdTabFact->Fact2 - MinSum;

				if (SumTab[SumTabInd])
					OKSumCntr++;
				PrdTabFact = PrdTabFact->Next;
			}
			if (OKSumCntr != 1)
				PrdTab[i].Flg = False;
		}
		else
			PrdTab[i].Flg = False;
}

void MrS2(_InpDat *InpDat, _PrdTab PrdTab, _SumTab SumTab, _OutDat *OutDat)
{
	LongNum i;
	LongNum Prd;
	LongNum SumTabInd;
	ShortNum FstNum = InpDat->FstNum;
	ShortNum Step = InpDat->Step;
	ShortNum MinSum = InpDat->MinSum;
	ShortNum MaxSum = InpDat->MaxSum;
	LongNum  MinPrd = InpDat->MinPrd;

	OutDat->Num = 0;
	for (i = MinSum + 2; i <= MaxSum; i++)
	{
		LongNum Fact1 = FstNum;
		LongNum Fact2;
		int  OKPrdCntr = 0;

		if (SumTab[i - MinSum])
			do
			{
				Fact2 = i - Fact1;
				Prd = (Fact1 * Fact2) - MinPrd;
				if (PrdTab[Prd].Flg)
					++OKPrdCntr;
				Fact1 += Step;
			} while (Fact1 <= i / 2);
			if (OKPrdCntr != 1)
				SumTab[i - MinSum] = False;
			else
			{
				SumTabInd = i;
				++OutDat->Num;
			}
	}
	if (OutDat->Num == 1)
	{
		for (i = FstNum; i <= SumTabInd / 2; i += Step)
		{
			LongNum j = SumTabInd - i;

			Prd = (i * j) - MinPrd;
			if (PrdTab[Prd].Flg)
			{
				OutDat->Fact1 = i;
				OutDat->Fact2 = j;
			}
		}
	}
}

void PrnRes(_OutDat *OutDat)
{
	if (OutDat->Num == 1)
		printf("\nRESULTS:\n--------\nNum1 = %d    Num2 = %d\n\n", OutDat->Fact1, OutDat->Fact2);
	else
		printf("\nNumber of solutions <> 1 (ResNo = %d), puzzle unsolvable!\n\n", OutDat->Num);
}
/*
Przyk³adowe dane wejœciowe i wyniki
Wejœcie		Wynik
2,350,4		2,18
6,200,2		26,32
9,300,3		39,48
2,99,1		4,13
*/
int main()
{
	_InpDat  *InpDat = (_InpDat *)malloc(sizeof(_InpDat));
	_OutDat  *OutDat = (_OutDat *)malloc(sizeof(_OutDat));

	InputData(InpDat);
	InitPrdTab(InpDat, PrdTab);
	InitSumTab(InpDat, SumTab);
	MrS1(InpDat, PrdTab, SumTab);
	MrP1(InpDat, PrdTab, SumTab);
	MrS2(InpDat, PrdTab, SumTab, OutDat);
	PrnRes(OutDat);
	getchar();
	getchar();
	return 0;
}
