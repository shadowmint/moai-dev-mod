// Copyright (c) 2010-2011 Zipline Games, Inc. All Rights Reserved.
// http://getmoai.com

#ifndef	GLUTHOST
#define	GLUTHOST

//----------------------------------------------------------------//
typedef void (*initfunc) (void);

//----------------------------------------------------------------//
int		GlutHost				( int argc, char** arg, initfunc );
void	GlutRefreshContext		();

#endif
