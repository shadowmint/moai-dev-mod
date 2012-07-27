// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef	GLUTHOST
#define	GLUTHOST

typedef void (* initfunc_t) ();

//----------------------------------------------------------------//
int		GlutHost				( int argc, char** arg, initfunc_t init );
void	GlutRefreshContext		();

#endif
