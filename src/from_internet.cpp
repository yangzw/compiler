// CodeParser.cpp : Defines the entry point for the console application.
//

//#include "stdafx.h"

#include <stdio.h>
#include <tchar.h>
#include <stdlib.h>
#include <conio.h>

#include <vector>
#include <string>
#include <map>
using namespace std;

// 符号表
enum eType
{
	Symbol
};
map<string, eType> g_mapSymbol;

enum eCharFlag
{
	noFlag,
	explain
};

eCharFlag g_charFlag = noFlag;

int _tmain(int argc, _TCHAR* argv[])
{
	// 输入常用标识符
	g_mapSymbol["if"] = Symbol;

	// 获取输入
	int i=0,j=0,k=0;
	char oneChar;
	char fname[200];
	memset(fname, 0, 200);
	printf("请输入要打开的文件名:\n");
	scanf("%s",fname);

	// for 测试
	//strcpy(fname, "d:\\1.cpp");

	// 打开文件
	FILE *fp;
	if ((fp= fopen(fname,"r"))== NULL)
	{
		printf("Cannot open infile.\n");
		exit(0); 
	}

	//int 0i;

	// 分析文件
	oneChar=fgetc(fp);
	char oneWord[256]={0};
	int nBuf = 0;
	vector<string> vecWords;
	while (oneChar!=EOF)
	{
		if(nBuf == 0)
		{
			if(oneChar == ' ' || oneChar == '\n' || oneChar == '\t')
			{

			}
			else if(oneChar == '(' || oneChar == '{')
			{
				oneWord[nBuf++]	= oneChar;
				string strWord = oneWord;
				vecWords.push_back(strWord);
				nBuf = 0;
				g_charFlag = noFlag;
				memset(oneWord, 0, 256);
				//continue;
			}
			else if(oneChar == ')' || oneChar == '}')
			{
				oneWord[nBuf++]	= oneChar;
				string strWord = oneWord;
				vecWords.push_back(strWord);
				nBuf = 0;
				g_charFlag = noFlag;
				memset(oneWord, 0, 256);
				//continue;
			}
			else if(oneChar >= '0' && oneChar <= '9')
			{
				/*printf("error, 不可以数字打头");
				return -1;*/
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar >= 'a' && oneChar <= 'z')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar >= 'A' && oneChar <= 'Z')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '#')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == ':')
			{
				// 界限符号
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '/')
			{
				// 注释的开始，找第二根横线
				// 或者是路径描述
				oneWord[nBuf++]	= oneChar;
				g_charFlag = explain;
			}
			else if(oneChar == '(')
			{
				// 函数的开始，找第二个括号
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == ')')
			{
				// 函数的结束
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '{')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '}')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == ';')
			{
				// 语句结束符
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '~')
			{
				// 析构函数符
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '\"')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '=')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '_')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '?')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else
			{
				//printf("未处理情况：%c", oneChar);
				oneWord[nBuf++]	= oneChar;
			}
		}
		else
		{
			if(oneChar == ' ' || oneChar == '\t' || oneChar == '\n')
			{
				if(g_charFlag != explain)
				{
					string strWord = oneWord;
					vecWords.push_back(strWord);
					nBuf = 0;
					g_charFlag = noFlag;
					memset(oneWord, 0, 256);
				}
				else if(g_charFlag == explain && oneChar == '\n')
				{
					// 如果是注释状态,则碰到回车才截断
					string strWord = oneWord;
					vecWords.push_back(strWord);
					nBuf = 0;
					g_charFlag = noFlag;
					memset(oneWord, 0, 256);
				}
			}
			else if(oneChar == '(' || oneChar == '{')
			{
				//oneWord[nBuf++]	= oneChar;
				string strWord = oneWord;
				vecWords.push_back(strWord);
				nBuf = 0;
				g_charFlag = noFlag;
				memset(oneWord, 0, 256);
				continue;
			}
			else if(oneChar == ')' || oneChar == '}')
			{
				//oneWord[nBuf++]	= oneChar;
				string strWord = oneWord;
				vecWords.push_back(strWord);
				nBuf = 0;
				g_charFlag = noFlag;
				memset(oneWord, 0, 256);
				continue;
			}
			//else if(oneChar == '\n')
			//{
			//	// 行末, 处理一些情况, 例如注释等
			//}
			else if(oneChar >= '0' && oneChar <= '9')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar >= 'a' && oneChar <= 'z')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar >= 'A' && oneChar <= 'Z')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '_')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == ':')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '(')
			{
				// 函数的开始，找第二个括号
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == ')')
			{
				// 函数的结束
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '{')
			{
				oneWord[nBuf++]	= oneChar;
			}	
			else if(oneChar == '}')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == ';')
			{
				// 语句结束符
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '~')
			{
				// 析构函数符
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '\"')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '*')
			{
				// 定义指针
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '.')
			{
				// .h
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '=')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '/')
			{
				// 如果是注释状态, 等待一行结束
				//if(g_charFlag == explain)
				{
					//oneWord[nBuf++]	= oneChar;
					//string strWord = oneWord;
					//vecWords.push_back(strWord);
					//nBuf = 0;
					////g_charFlag = noFlag;	
					//memset(oneWord, 0, 256);
					//oneWord[nBuf++]	= oneChar;
				}
				//else
				{
					oneWord[nBuf++]	= oneChar;
				}
			}
			else if(oneChar == ',')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else if(oneChar == '?')
			{
				oneWord[nBuf++]	= oneChar;
			}
			else
			{
				oneWord[nBuf++]	= oneChar;
				//printf("未处理情况：%c", oneChar);

				//string strWord = "未处理情况：%s";
				//printf("error, 未处理情况.");
				//return -1;
			}
		}
		oneChar=fgetc(fp);
	}
	fclose(fp);

	// 写入文件
	FILE *fpIn;
	if ((fpIn= fopen("d:\\words.txt","w+"))== NULL)
	{
		printf("Cannot open infile.\n");
		exit(0); 
	}
	
	for(int i = 0; i < vecWords.size(); i++)
	{
		char szBuf[300];
		memset(szBuf, 0, 300);
		sprintf(szBuf, "%d. %s\n", i, vecWords[i].c_str());
		fwrite(szBuf, strlen(szBuf), 1, fpIn);
		//printf("%d. %s\n", i, vecWords[i].c_str());
	}
	fclose(fpIn);

	// 语法解析
	// 首先要对括号进行匹配,验证语法等

	vector<string> vecClass;	// 解析出类
	vector<string> vecHeader;	// 解析出头文件

	typedef struct
	{
		string funcName;
		string paramList;
	}stFunc;

	vector<stFunc> vecFunc;		// 解析出函数

	for(int i = 0; i < vecWords.size(); i++)
	{
		if(vecWords[i] == "#include" )
		{
			// 语法分析会随着词法分析结果而变化

			//if(i > 0)
			//{
			//	// 没被注释掉的头文件
			//	if(vecWords[i-1] != "//")
			//	{
			//		vecHeader.push_back(vecWords[i+1]);
			//	}
			//}	
			
			vecHeader.push_back(vecWords[i+1]);
		}
		else if(vecWords[i] == "(")
		{
			// 前面是函数名, 后面是参数
			if(i > 0)
			{
				if(g_mapSymbol.find(vecWords[i-1]) != g_mapSymbol.end())
				{
					//  说明是标准标示词,不是函数
					continue;
				}
				stFunc f;
				f.funcName = vecWords[i-1];
				string strParamList = "(";
				while(vecWords[i++] != ")")
				{
					if(vecWords[i] == "(")
					{
						strParamList += "(";
						while(vecWords[i++] != ")")
						{
							strParamList += " ";
							strParamList += vecWords[i];
						}
					}
					strParamList += " ";
					strParamList += vecWords[i];					
				}
				f.paramList = strParamList;
				vecFunc.push_back(f);
			}
		}
		else if(vecWords[i] == "()")
		{
			// 前面是函数名, 中间无参数
			if(i > 0)
			{
				stFunc f;
				f.funcName = vecWords[i-1];
				f.paramList = "";	
				vecFunc.push_back(f);
			}
		}
		else if(vecWords[i] == "class")
		{
			// 后一个是类名
			string strClass = vecWords[i+1];
			vecClass.push_back(strClass);
		}
	}

	// Grammar 写入文件
	if ((fpIn= fopen("d:\\grammar.txt","w+"))== NULL)
	{
		printf("Cannot open infile.\n");
		exit(0); 
	}

	// 头文件
	for(int i = 0; i < vecHeader.size(); i++)
	{
		char szBuf[500];
		memset(szBuf, 0, 500);
		sprintf(szBuf, "%d. %s \n", i, vecHeader[i].c_str());
		fwrite(szBuf, strlen(szBuf), 1, fpIn);
	}

	fwrite("\n\n\n", 2, 1, fpIn);

	// 类名
	for(int i = 0; i < vecClass.size(); i++)
	{
		char szBuf[500];
		memset(szBuf, 0, 500);
		sprintf(szBuf, "%d. %s \n", i, vecClass[i].c_str());
		fwrite(szBuf, strlen(szBuf), 1, fpIn);
	}

	fwrite("\n\n\n", 2, 1, fpIn);


	// 函数
	for(int i = 0; i < vecFunc.size(); i++)
	{
		char szBuf[500];
		memset(szBuf, 0, 500);
		sprintf(szBuf, "%d. %s %s \n", i, vecFunc[i].funcName.c_str(), vecFunc[i].paramList.c_str());
		fwrite(szBuf, strlen(szBuf), 1, fpIn);
		//printf("%d. %s\n", i, vecWords[i].c_str());
	}
	fclose(fpIn);


	// 解析完成
	printf("解析完成...\n");
	printf("词法分析结果: d:\\words.txt  语法分析结果: d:\\grammar.txt, 请输入任何键结束...\n");
	getch();

	return 0;
}

