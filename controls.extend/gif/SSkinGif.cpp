#include "StdAfx.h"
#include "SSkinGif.h"
#include <helper/SplitString.h>
#include <interface/SImgDecoder-i.h>
#include <interface/SRender-i.h>

using namespace Gdiplus;
#pragma comment(lib,"gdiplus.lib")

namespace SOUI
{

    HRESULT SSkinGif::OnAttrSrc( const SStringW &strValue,BOOL bLoading )
    {
        SStringTList strLst;
        size_t nSegs=ParseResID(S_CW2T(strValue),strLst);
        LPBYTE pBuf=NULL;
        size_t szBuf=0;

        if(nSegs == 2)
        {
            szBuf=GETRESPROVIDER->GetRawBufferSize(strLst[0],strLst[1]);
            if(szBuf)
            {
                pBuf=new BYTE[szBuf];
                GETRESPROVIDER->GetRawBuffer(strLst[0],strLst[1],pBuf,szBuf);
            }
        }else
        {//�Զ���GIF��Դ�����������Դ
            szBuf=GETRESPROVIDER->GetRawBufferSize(_T("gif"),strLst[0]);
            if(szBuf)
            {
                pBuf=new BYTE[szBuf];
                GETRESPROVIDER->GetRawBuffer(_T("gif"),strLst[0],pBuf,szBuf);
            }
        }
        if(pBuf)
        {
            LoadFromMemory(pBuf,szBuf);
            delete []pBuf;
        }
        return S_OK;
    }

int SSkinGif::LoadFromFile( LPCTSTR pszFileName )
{
    if (m_pImg)
    {
		delete m_pImg;
    }
    m_pImg = Bitmap::FromFile(S_CT2W(pszFileName));
    if(!m_pImg) return 0;
    if(m_pImg->GetLastStatus() != Gdiplus::Ok)
    {
        delete m_pImg;
		m_pImg = NULL;
        return 0;
    }

    LoadFromGdipImage(m_pImg);
    return m_nFrames;
}

int SSkinGif::LoadFromMemory( LPVOID pBuf,size_t dwSize )
{
    HGLOBAL hMem = ::GlobalAlloc(GMEM_FIXED, dwSize);
    BYTE* pMem = (BYTE*)::GlobalLock(hMem);

    memcpy(pMem, pBuf, dwSize);

    IStream* pStm = NULL;
    ::CreateStreamOnHGlobal(hMem, TRUE, &pStm);
	if (m_pImg)
	{
		delete m_pImg;
	}
	m_pImg = Gdiplus::Bitmap::FromStream(pStm);
	if (!m_pImg) return 0;
	if (m_pImg->GetLastStatus() != Gdiplus::Ok)
    {
        pStm->Release();
        ::GlobalUnlock(hMem);
		delete m_pImg;
		m_pImg = NULL;
        return 0;
    }

    LoadFromGdipImage(m_pImg);

    return m_nFrames;
}

int SSkinGif::LoadFrame(int i, Gdiplus::Bitmap * pImage) const
{
    if (m_pFrames && i < m_nFrames)
    {		
		pImage->SelectActiveFrame(&FrameDimensionTime, i);
		Bitmap bmp(pImage->GetWidth(), pImage->GetHeight(), PixelFormat32bppPARGB);
		Graphics g(&bmp);
		g.DrawImage(pImage, 0, 0);
		Gdiplus::Rect rc;
		rc.Width = pImage->GetWidth();
		rc.Height = pImage->GetHeight();
		BitmapData data;
		bmp.LockBits(&rc, 0, PixelFormat32bppPARGB, &data);
		m_pCurFrameBmp->Init(data.Width, data.Height, data.Scan0);
		bmp.UnlockBits(&data);

		return 0;
    }
	return 1;
}
	
int SSkinGif::LoadFromGdipImage( Gdiplus::Bitmap * pImage )
{
	if (m_nFrames)
	{
		SASSERT(m_pFrames);
		delete[]m_pFrames;
		m_pFrames = NULL;
		m_nFrames = 0;
	}

    UINT nCount = pImage->GetFrameDimensionsCount();

    GUID* pDimensionIDs = new GUID[nCount];
    if (pDimensionIDs != NULL)
    {
        pImage->GetFrameDimensionsList(pDimensionIDs, nCount);
        m_nFrames = pImage->GetFrameCount(&pDimensionIDs[0]);
        delete pDimensionIDs;
    }
    m_pFrames = new SAniFrame[m_nFrames];
    UINT nSize = pImage->GetPropertyItemSize(PropertyTagFrameDelay);
    SASSERT (nSize);

    Gdiplus::PropertyItem * pPropertyItem = (Gdiplus::PropertyItem *)malloc(nSize);
    if (pPropertyItem != NULL)
    {
        pImage->GetPropertyItem(PropertyTagFrameDelay, nSize, pPropertyItem);
        for(int i=0;i<m_nFrames;i++)
        {
            m_pFrames[i].nDelay = ((long*)pPropertyItem->value)[i];
        }
        free(pPropertyItem);
    }

	GETRENDERFACTORY->CreateBitmap((IBitmap**)&m_pCurFrameBmp);
	LoadFrame(0, pImage);

    return m_nFrames;
}

static ULONG_PTR s_gdipToken=0;



/**
* GetFrameDelay
* @brief    ���ָ��֡����ʾʱ��
* @param    int iFrame --  ֡��,Ϊ-1ʱ�����õ�ǰ֡����ʱ
* @return   long -- ��ʱʱ��(*10ms)
* Describe
*/

long SSkinGif::GetFrameDelay(int iFrame) const
{
	if (iFrame == -1) iFrame = m_iFrame;
	long nRet = -1;
	if (m_nFrames>1 && iFrame >= 0 && iFrame<m_nFrames)
	{
		nRet = m_pFrames[iFrame].nDelay;
	}
	return nRet;
}

BOOL SSkinGif::Gdiplus_Startup()
{
    GdiplusStartupInput gdiplusStartupInput;
    Status st=GdiplusStartup(&s_gdipToken, &gdiplusStartupInput, NULL);
    return st==0;

}

void SSkinGif::Gdiplus_Shutdown()
{
    GdiplusShutdown(s_gdipToken);
}

void SSkinGif::_DrawByIndex2(IRenderTarget *pRT, LPCRECT rcDraw, int iState, BYTE byAlpha) const
{
	if (iState < m_nFrames)
	{
		LoadFrame(iState, m_pImg);
		CRect rcSrc(CPoint(0, 0), GetSkinSize());
		if (m_bEnableScale)
			pRT->DrawBitmapEx(rcDraw, m_pCurFrameBmp, rcSrc, m_bTile ? EM_TILE : EM_STRETCH, byAlpha);
		else
			pRT->DrawBitmapEx(rcDraw, m_pCurFrameBmp, rcSrc, EM_NULL, byAlpha);
	}
}

SIZE SSkinGif::GetSkinSize() const
{
	CSize szRet;
	if (m_pFrames && m_nFrames>0)
	{
		szRet.cx = m_pCurFrameBmp->Width();
		szRet.cy = m_pCurFrameBmp->Height();
	}
	return szRet;
}

int SSkinGif::GetStates() const
{
	return m_nFrames;
}

}//end of namespace SOUI