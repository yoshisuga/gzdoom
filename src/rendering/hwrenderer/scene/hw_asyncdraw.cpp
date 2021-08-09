// 
//---------------------------------------------------------------------------
//
// Copyright(C) 2000-2016 Christoph Oelckers
// All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/
//
//--------------------------------------------------------------------------
//
/*
** gl_bsp.cpp
** Main rendering loop / BSP traversal / visibility clipping
**
**/

#include <atomic>
#include "hw_renderstate.h"
#include "hw_drawinfo.h"
#include "hw_drawstructs.h"
#include "hw_clock.h"
#include "hw_cvars.h"

EXTERN_CVAR(Bool, gl_texture)



struct DrawJob
{
	int type;
	void* data;
};


class DrawJobQueue
{
	DrawJob pool[300000];	// Way more than ever needed. The largest ever seen on a single viewpoint is around 40000.
	std::atomic<int> readindex{};
	std::atomic<int> writeindex{};
public:
	void AddJob(int type, void* data)
	{
		// This does not check for array overflows. The pool should be large enough that it never hits the limit.
		pool[writeindex] = { type, data };
		writeindex++;	// update index only after the value has been written.
	}

	DrawJob *GetJob()
	{
		if (readindex < writeindex) return &pool[readindex++];
		return nullptr;
	}
	
	void ReleaseAll()
	{
		readindex = 0;
		writeindex = 0;
	}
};

static DrawJobQueue drawQueue;	// One static queue is sufficient here. This code will never be called recursively.

void mt_renderloop(HWDrawInfo* di, FRenderState& state)
{
	state.SetDepthMask(true);
	state.EnableFog(true);
	state.SetRenderStyle(STYLE_Source);

	// Part 1: solid geometry. This is set up so that there are no transparent parts
	state.SetDepthFunc(DF_Less);
	state.ClearDepthBias();
	state.EnableTexture(gl_texture);
	state.EnableBrightmap(true);
	
	//WTTotal.Clock();
	while (true)
	{
		auto job = drawQueue.GetJob();
		if (job == nullptr)
		{
#ifdef ARCH_IA32
			// The queue is empty. But yielding would be too costly here and possibly cause further delays down the line if the thread is halted.
			// So instead add a few pause instructions and retry immediately.
			_mm_pause();
			_mm_pause();
			_mm_pause();
			_mm_pause();
			_mm_pause();
			_mm_pause();
			_mm_pause();
			_mm_pause();
			_mm_pause();
			_mm_pause();
#endif // ARCH_IA32
		}
		// Note that the main thread MUST have prepared the fake sectors that get used below!
		// This worker thread cannot prepare them itself without costly synchronization.
		else switch (job->type)
		{
		case GLDL_PLAINWALLS:
			RenderWallAsync.Clock();
			state.AlphaFunc(Alpha_GEqual, 0.f);
			reinterpret_cast<HWWall*>(job->data)->DrawWall(di, state, false);
			RenderWallAsync.Unclock();
			break;

		case GLDL_MASKEDWALLS:
			RenderWallAsync.Clock();
			state.AlphaFunc(Alpha_GEqual, gl_mask_threshold);
			reinterpret_cast<HWWall*>(job->data)->DrawWall(di, state, false);
			RenderWallAsync.Unclock();
			break;

		case GLDL_PLAINFLATS:
			RenderFlatAsync.Clock();
			state.AlphaFunc(Alpha_GEqual, 0.f);
			reinterpret_cast<HWFlat*>(job->data)->DrawFlat(di, state, false);
			RenderFlatAsync.Unclock();
			break;

		case GLDL_MASKEDFLATS:
			RenderFlatAsync.Clock();
			state.AlphaFunc(Alpha_GEqual, gl_mask_threshold);
			reinterpret_cast<HWFlat*>(job->data)->DrawFlat(di, state, false);
			RenderFlatAsync.Unclock();
			break;

		default:
			return;
		}

	}
}


void mt_draw(int list, void* data)
{
	drawQueue.AddJob(list, data);
}
