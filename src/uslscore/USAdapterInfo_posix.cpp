/*	Useless Technologies - Version 1.0
	All contents Copyright (c) 2009 by Patrick Meehan
	
	Permission is hereby granted, free of charge, to any person
	obtaining a copy of this software and associated documentation
	files (the "Software"), to deal in the Software without
	restriction, including without limitation the rights to use,
	copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following
	conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.
*/

#include "pch.h"

#ifndef _WIN32

#include <uslscore/USAdapterInfo.h>

#if !( NACL || ANDROID )
  #ifdef __APPLE__
    #include <sys/socket.h>
    #include <sys/sysctl.h>
    #include <net/if.h>
    #include <net/if_dl.h>
  #else
    #include <sys/ioctl.h>
    #include <net/if.h> 
    #include <unistd.h>
    #include <netinet/in.h>
    #include <string.h>
  #endif
#endif

//================================================================//
// USAdapterInfo
//================================================================//

//----------------------------------------------------------------//
void USAdapterInfo::SetNameFromMACAddress ( u8* address, u32 length ) {
	UNUSED ( address );
	UNUSED ( length );

	this->mName = "Unimplemented - Do Not Use!";
}

STLString USAdapterInfo::GetMACAddress () {
	
	char * msgBuffer = NULL;
	USMacAddress macAddress;
	memset ( macAddress.bytes , 0 , 6 );
    
#if !( NACL || ANDROID )
  #ifdef __APPLE__
    int mgmtInfoBase[6];
    mgmtInfoBase[0] = CTL_NET;
    mgmtInfoBase[1] = AF_ROUTE;
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;
    mgmtInfoBase[4] = NET_RT_IFLIST;
    
    if ( !(( mgmtInfoBase [ 5 ] = if_nametoindex ( "en0" )) == 0 ) ) {

      size_t length;
      if ( !( sysctl ( mgmtInfoBase, 6, NULL, &length, NULL, 0 ) < 0 ) ) {

        if ( !(( msgBuffer = ( char * ) malloc ( length )) == NULL ) ) {

          if ( sysctl ( mgmtInfoBase, 6, msgBuffer, &length, NULL, 0 ) < 0 ) {
            // error
          }
          
          struct if_msghdr *interfaceMsgStruct = ( struct if_msghdr * ) msgBuffer;
          
          struct sockaddr_dl *socketStruct = ( struct sockaddr_dl * ) ( interfaceMsgStruct + 1 );
          
          memcpy ( macAddress.bytes, socketStruct->sdl_data + socketStruct->sdl_nlen, 6 );
          
          free(msgBuffer);
        }
      }
    }
  #else
    struct ifreq ifr;
    struct ifconf ifc;
    char buf[1024];
    int success = 0;

    int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    if (sock == -1) { /* handle error*/ };

    ifc.ifc_len = sizeof(buf);
    ifc.ifc_buf = buf;
    if (ioctl(sock, SIOCGIFCONF, &ifc) == -1) { /* handle error */ }

    struct ifreq* it = ifc.ifc_req;
    const struct ifreq* const end = it + (ifc.ifc_len / sizeof(struct ifreq));

    for (; it != end; ++it) {
        strcpy(ifr.ifr_name, it->ifr_name);
        if (ioctl(sock, SIOCGIFFLAGS, &ifr) == 0) {
            if (! (ifr.ifr_flags & IFF_LOOPBACK)) { // don't count loopback
                if (ioctl(sock, SIOCGIFHWADDR, &ifr) == 0) {
                    success = 1;
                    break;
                }
            }
        }
        else { /* handle error */ }
    }

    unsigned char mac_address[6];

    if (success) memcpy(mac_address, ifr.ifr_hwaddr.sa_data, 6);
  #endif
#else
	//ANDROID NOT IMPLEMENTED
#endif
	
	char address[13];
	memset ( address , 0 , 13 );
	
	sprintf( address, "%02X%02X%02X%02X%02X%02X", macAddress.bytes[0], macAddress.bytes[1], macAddress.bytes[2], macAddress.bytes[3], macAddress.bytes[4], macAddress.bytes[5] );
	STLString macString = address;
	return macString;	
}
//================================================================//
// USAdapterInfoList
//================================================================//

//----------------------------------------------------------------//
void USAdapterInfoList::EnumerateAdapters () {

}

#endif

