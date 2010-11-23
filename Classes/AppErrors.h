/*
 *  AppErrors.h
 *  iPapka
 *
 *  Created by Vladimir Solomenchuk on 23.11.10.
 *  Copyright 2010 Intertrust Company. All rights reserved.
 *
 */

#define isAppError(error, errorCode)\
([error.domain isEqualToString:@"ru.intertrust.cm.iPapka"] &&error.code == errorCode)

#define NSErrorWithCode(errorCode)\
[NSError errorWithDomain:@"ru.intertrust.cm.iPapka" code:errorCode userInfo:nil]


#define ERROR_IPAPKA_SERVER 1000
#define ERROR_IPAPKA_CONFLICT 1001
