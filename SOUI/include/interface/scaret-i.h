#pragma once
#include <unknown/obj-ref-i.h>
#include <sobject/sobject-i.h>
#include <interface/STimelineHandler-i.h>

namespace SOUI
{
	struct SOUI_EXP ICaret : public IObjRef, public IObject, public ITimelineHandler
	{
		virtual BOOL Init(HBITMAP hBmp, int nWid, int nHei) = 0;

		virtual void SetPosition(int x, int y) = 0;

		virtual BOOL SetVisible(BOOL bVisible,SWND owner) = 0;

		virtual BOOL IsVisible() const = 0;

		virtual void Draw(IRenderTarget *pRT) = 0;

		virtual RECT GetRect() const = 0;
	};

}