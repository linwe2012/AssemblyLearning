/* L ASM
* author: leon lin
* github: linwe2012 
* First version: 2018-10-29
* liscensed under GPLv3
*
* Description:
* A small library that implement basic asm command
* macro like `_ABC()` will return the result
* yet `ABC()` will directly change the input
* 
*/

#ifndef __GNUC__
#ifndef _MSC_VER
#error "Unsupported Compiler. Please use GCC or MIicrosoft Complier"
#endif // !_MSC_VER
#endif

// ({}) is an xtension of GNUC, which is not available in MSC
#ifdef __GNUC__
#define _ROLB(origin, cnt) _LASM_ROTATE(origin, cnt, rol, b, cl, al)
#define _RORB(origin, cnt) _LASM_ROTATE(origin, cnt, ror, b, cl, al)
#endif

#define RORB(origin, cnt) LASM_ROTATE(origin, cnt, ror, b, cl, al)
#define ROLB(origin, cnt) LASM_ROTATE(origin, cnt, rol, b, cl, al)

#define _LASM_ROTATE(origin, cnt, method, type, regcnt, regOrg) ({\
	int __res;\
	_CORE_LASM_ROTATE(origin, cnt, __res, method, type, regcnt, regOrg)\
	__res;\
})

#define LASM_ROTATE(origin, cnt, method, type, regcnt, regOrg)\
	do{\
	_CORE_LASM_ROTATE(origin, cnt, origin, method, type, regcnt, regOrg)\
	}while(0)
	
/* ror or rol implement
* [in]origin:the input
* [in]cnt: how many input
* [in]method: rorb, rorl, rol etc.
* [in]regcnt: cl, cx, ecx, rcx
* [in]regOrg: al, ax, eax, rax
*
* [out]__res: result;
*/
#ifdef __GNUC__
#define _CORE_LASM_ROTATE(origin, cnt, res, method, type, regcnt, regOrg) __asm__( \
	#method #type " %%" #regcnt ", %%" #regOrg "\n"   \
	:"=a"(res)           \
	:"a"(origin), "c"(cnt) \
	);      
#endif      
#ifdef _MSC_VER
#define _CORE_LASM_ROTATE(origin, cnt, res, method, type, regcnt, regOrg) __asm{ \
	__asm mov eax, origin         \
	__asm mov ecx, cnt            \
	__asm method regOrg, regcnt   \
	__asm mov res, eax      \
	}; 
#endif         
