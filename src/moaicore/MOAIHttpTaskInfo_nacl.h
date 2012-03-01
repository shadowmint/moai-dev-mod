// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef MOAIHTTPTASK_NACL_H
#define MOAIHTTPTASK_NACL_H

#include <moaicore/MOAIHttpTaskBase.h>

#ifdef MOAI_OS_NACL

#include "geturl_handler.h"

//================================================================//
// MOAIHttpTask
//================================================================//
class MOAIHttpTask :
	public MOAIHttpTaskBase {
private:
	STLString			mUrl;
	USLeanArray < u8 >	mBody;
	int mMethod;

	USMemStream			mMemStream;
	USByteStream		mByteStream;
	
	USStream*			mStream;

	bool				mReady;

	bool				mLock;

	const void *		mTempBufferToCopy;
	int					mTempBufferToCopySize;

	friend class MOAIUrlMgr;

	static void HttpLoaded ( GetURLHandler *handler, const char *buffer, int32_t size );
	static void HttpGetMainThread ( void* userData, int32_t result );

	void Prepare ( GetURLHandler *handler );


public:

	DECL_LUA_FACTORY ( MOAIHttpTask )

	//----------------------------------------------------------------//
					MOAIHttpTask			();
					~MOAIHttpTask			();

	void			PerformAsync			();
	void			PerformSync				();
	void			RegisterLuaClass		( MOAILuaState& state );
	void			RegisterLuaFuncs		( MOAILuaState& state );
	void			Reset					();
	void			SetBody					( const void* buffer, u32 size );
	void			SetUrl					( cc8* url );
	void			SetUserAgent			( cc8* useragent );
	void			SetVerb					( u32 verb );
	void			SetVerbose				( bool verbose );

	void			Clear					();
	void			NaClFinish				();
};

#endif
#endif