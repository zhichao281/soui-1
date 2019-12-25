#pragma once

namespace SOUI
{

	/**
	* @union      FONTSTYLE
	* @brief      FONT�ķ��
	* 
	* Describe    
	*/
	union FONTSTYLE{
		DWORD     dwStyle;  //DWORD�汾�ķ��
		struct 
		{
			DWORD byCharset:8;  //�ַ���
			DWORD byWeight :8;  //weight/4
			DWORD fItalic:1;//б���־λ
			DWORD fUnderline:1;//�»��߱�־λ
			DWORD fBold:1;//�����־λ
			DWORD fStrike:1;//ɾ���߱�־λ
			DWORD cSize : 12; //�����С��Ϊshort�з�������
		}attr;

		FONTSTYLE(DWORD _dwStyle=0):dwStyle(_dwStyle){}
	}; 

	struct FontInfo
	{
		FONTSTYLE style;
		SStringW strFaceName;
		SStringW strPropEx;
	};
}