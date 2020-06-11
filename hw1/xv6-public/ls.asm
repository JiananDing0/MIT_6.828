
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
  close(fd);
}

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 e4 f0             	and    $0xfffffff0,%esp
   9:	83 ec 10             	sub    $0x10,%esp
   c:	8b 75 08             	mov    0x8(%ebp),%esi
   f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  if(argc < 2){
  12:	83 fe 01             	cmp    $0x1,%esi
  15:	7e 1a                	jle    31 <main+0x31>
  17:	bb 01 00 00 00       	mov    $0x1,%ebx
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
  1c:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 b1 00 00 00       	call   d8 <ls>

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
  27:	43                   	inc    %ebx
  28:	39 f3                	cmp    %esi,%ebx
  2a:	75 f0                	jne    1c <main+0x1c>
    ls(argv[i]);
  exit();
  2c:	e8 bf 04 00 00       	call   4f0 <exit>
main(int argc, char *argv[])
{
  int i;

  if(argc < 2){
    ls(".");
  31:	c7 04 24 fa 08 00 00 	movl   $0x8fa,(%esp)
  38:	e8 9b 00 00 00       	call   d8 <ls>
    exit();
  3d:	e8 ae 04 00 00       	call   4f0 <exit>
  42:	90                   	nop
  43:	90                   	nop

00000044 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
  44:	55                   	push   %ebp
  45:	89 e5                	mov    %esp,%ebp
  47:	56                   	push   %esi
  48:	53                   	push   %ebx
  49:	83 ec 10             	sub    $0x10,%esp
  4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  4f:	89 1c 24             	mov    %ebx,(%esp)
  52:	e8 39 03 00 00       	call   390 <strlen>
  57:	01 d8                	add    %ebx,%eax
  59:	73 0a                	jae    65 <fmtname+0x21>
  5b:	eb 0d                	jmp    6a <fmtname+0x26>
  5d:	8d 76 00             	lea    0x0(%esi),%esi
  60:	48                   	dec    %eax
  61:	39 c3                	cmp    %eax,%ebx
  63:	77 05                	ja     6a <fmtname+0x26>
  65:	80 38 2f             	cmpb   $0x2f,(%eax)
  68:	75 f6                	jne    60 <fmtname+0x1c>
    ;
  p++;
  6a:	8d 58 01             	lea    0x1(%eax),%ebx

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  6d:	89 1c 24             	mov    %ebx,(%esp)
  70:	e8 1b 03 00 00       	call   390 <strlen>
  75:	83 f8 0d             	cmp    $0xd,%eax
  78:	77 53                	ja     cd <fmtname+0x89>
    return p;
  memmove(buf, p, strlen(p));
  7a:	89 1c 24             	mov    %ebx,(%esp)
  7d:	e8 0e 03 00 00       	call   390 <strlen>
  82:	89 44 24 08          	mov    %eax,0x8(%esp)
  86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8a:	c7 04 24 20 0c 00 00 	movl   $0xc20,(%esp)
  91:	e8 2e 04 00 00       	call   4c4 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  96:	89 1c 24             	mov    %ebx,(%esp)
  99:	e8 f2 02 00 00       	call   390 <strlen>
  9e:	89 c6                	mov    %eax,%esi
  a0:	89 1c 24             	mov    %ebx,(%esp)
  a3:	e8 e8 02 00 00       	call   390 <strlen>
  a8:	ba 0e 00 00 00       	mov    $0xe,%edx
  ad:	29 f2                	sub    %esi,%edx
  af:	89 54 24 08          	mov    %edx,0x8(%esp)
  b3:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  ba:	00 
  bb:	05 20 0c 00 00       	add    $0xc20,%eax
  c0:	89 04 24             	mov    %eax,(%esp)
  c3:	e8 e8 02 00 00       	call   3b0 <memset>
  return buf;
  c8:	bb 20 0c 00 00       	mov    $0xc20,%ebx
}
  cd:	89 d8                	mov    %ebx,%eax
  cf:	83 c4 10             	add    $0x10,%esp
  d2:	5b                   	pop    %ebx
  d3:	5e                   	pop    %esi
  d4:	5d                   	pop    %ebp
  d5:	c3                   	ret    
  d6:	66 90                	xchg   %ax,%ax

000000d8 <ls>:

void
ls(char *path)
{
  d8:	55                   	push   %ebp
  d9:	89 e5                	mov    %esp,%ebp
  db:	57                   	push   %edi
  dc:	56                   	push   %esi
  dd:	53                   	push   %ebx
  de:	81 ec 7c 02 00 00    	sub    $0x27c,%esp
  e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  ee:	00 
  ef:	89 3c 24             	mov    %edi,(%esp)
  f2:	e8 39 04 00 00       	call   530 <open>
  f7:	89 c3                	mov    %eax,%ebx
  f9:	85 c0                	test   %eax,%eax
  fb:	0f 88 bb 01 00 00    	js     2bc <ls+0x1e4>
    printf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
 101:	8d 75 c4             	lea    -0x3c(%ebp),%esi
 104:	89 74 24 04          	mov    %esi,0x4(%esp)
 108:	89 04 24             	mov    %eax,(%esp)
 10b:	e8 38 04 00 00       	call   548 <fstat>
 110:	85 c0                	test   %eax,%eax
 112:	0f 88 ec 01 00 00    	js     304 <ls+0x22c>
    printf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
 118:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 11b:	66 83 f8 01          	cmp    $0x1,%ax
 11f:	74 5f                	je     180 <ls+0xa8>
 121:	66 83 f8 02          	cmp    $0x2,%ax
 125:	74 15                	je     13c <ls+0x64>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 127:	89 1c 24             	mov    %ebx,(%esp)
 12a:	e8 e9 03 00 00       	call   518 <close>
}
 12f:	81 c4 7c 02 00 00    	add    $0x27c,%esp
 135:	5b                   	pop    %ebx
 136:	5e                   	pop    %esi
 137:	5f                   	pop    %edi
 138:	5d                   	pop    %ebp
 139:	c3                   	ret    
 13a:	66 90                	xchg   %ax,%ax
    return;
  }

  switch(st.type){
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 13c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
 13f:	8b 75 cc             	mov    -0x34(%ebp),%esi
 142:	89 3c 24             	mov    %edi,(%esp)
 145:	89 95 a8 fd ff ff    	mov    %edx,-0x258(%ebp)
 14b:	e8 f4 fe ff ff       	call   44 <fmtname>
 150:	8b 95 a8 fd ff ff    	mov    -0x258(%ebp),%edx
 156:	89 54 24 14          	mov    %edx,0x14(%esp)
 15a:	89 74 24 10          	mov    %esi,0x10(%esp)
 15e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
 165:	00 
 166:	89 44 24 08          	mov    %eax,0x8(%esp)
 16a:	c7 44 24 04 da 08 00 	movl   $0x8da,0x4(%esp)
 171:	00 
 172:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 179:	e8 a2 04 00 00       	call   620 <printf>
    break;
 17e:	eb a7                	jmp    127 <ls+0x4f>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 180:	89 3c 24             	mov    %edi,(%esp)
 183:	e8 08 02 00 00       	call   390 <strlen>
 188:	83 c0 10             	add    $0x10,%eax
 18b:	3d 00 02 00 00       	cmp    $0x200,%eax
 190:	0f 87 0a 01 00 00    	ja     2a0 <ls+0x1c8>
      printf(1, "ls: path too long\n");
      break;
    }
    strcpy(buf, path);
 196:	89 7c 24 04          	mov    %edi,0x4(%esp)
 19a:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 1a0:	89 04 24             	mov    %eax,(%esp)
 1a3:	e8 84 01 00 00       	call   32c <strcpy>
    p = buf+strlen(buf);
 1a8:	8d 95 c4 fd ff ff    	lea    -0x23c(%ebp),%edx
 1ae:	89 14 24             	mov    %edx,(%esp)
 1b1:	e8 da 01 00 00       	call   390 <strlen>
 1b6:	8d 8d c4 fd ff ff    	lea    -0x23c(%ebp),%ecx
 1bc:	01 c1                	add    %eax,%ecx
 1be:	89 8d b4 fd ff ff    	mov    %ecx,-0x24c(%ebp)
    *p++ = '/';
 1c4:	c6 01 2f             	movb   $0x2f,(%ecx)
 1c7:	41                   	inc    %ecx
 1c8:	89 8d ac fd ff ff    	mov    %ecx,-0x254(%ebp)
 1ce:	8d 7d d8             	lea    -0x28(%ebp),%edi
 1d1:	8d 76 00             	lea    0x0(%esi),%esi
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1d4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 1db:	00 
 1dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
 1e0:	89 1c 24             	mov    %ebx,(%esp)
 1e3:	e8 20 03 00 00       	call   508 <read>
 1e8:	83 f8 10             	cmp    $0x10,%eax
 1eb:	0f 85 36 ff ff ff    	jne    127 <ls+0x4f>
      if(de.inum == 0)
 1f1:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
 1f6:	74 dc                	je     1d4 <ls+0xfc>
        continue;
      memmove(p, de.name, DIRSIZ);
 1f8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 1ff:	00 
 200:	8d 45 da             	lea    -0x26(%ebp),%eax
 203:	89 44 24 04          	mov    %eax,0x4(%esp)
 207:	8b 95 ac fd ff ff    	mov    -0x254(%ebp),%edx
 20d:	89 14 24             	mov    %edx,(%esp)
 210:	e8 af 02 00 00       	call   4c4 <memmove>
      p[DIRSIZ] = 0;
 215:	8b 8d b4 fd ff ff    	mov    -0x24c(%ebp),%ecx
 21b:	c6 41 0f 00          	movb   $0x0,0xf(%ecx)
      if(stat(buf, &st) < 0){
 21f:	89 74 24 04          	mov    %esi,0x4(%esp)
 223:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 229:	89 04 24             	mov    %eax,(%esp)
 22c:	e8 17 02 00 00       	call   448 <stat>
 231:	85 c0                	test   %eax,%eax
 233:	0f 88 a7 00 00 00    	js     2e0 <ls+0x208>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 239:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
 23c:	8b 55 cc             	mov    -0x34(%ebp),%edx
 23f:	89 95 b0 fd ff ff    	mov    %edx,-0x250(%ebp)
 245:	0f bf 55 c4          	movswl -0x3c(%ebp),%edx
 249:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 24f:	89 04 24             	mov    %eax,(%esp)
 252:	89 95 a8 fd ff ff    	mov    %edx,-0x258(%ebp)
 258:	89 8d a4 fd ff ff    	mov    %ecx,-0x25c(%ebp)
 25e:	e8 e1 fd ff ff       	call   44 <fmtname>
 263:	8b 8d a4 fd ff ff    	mov    -0x25c(%ebp),%ecx
 269:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 26d:	8b 8d b0 fd ff ff    	mov    -0x250(%ebp),%ecx
 273:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 277:	8b 95 a8 fd ff ff    	mov    -0x258(%ebp),%edx
 27d:	89 54 24 0c          	mov    %edx,0xc(%esp)
 281:	89 44 24 08          	mov    %eax,0x8(%esp)
 285:	c7 44 24 04 da 08 00 	movl   $0x8da,0x4(%esp)
 28c:	00 
 28d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 294:	e8 87 03 00 00       	call   620 <printf>
 299:	e9 36 ff ff ff       	jmp    1d4 <ls+0xfc>
 29e:	66 90                	xchg   %ax,%ax
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
    break;

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
      printf(1, "ls: path too long\n");
 2a0:	c7 44 24 04 e7 08 00 	movl   $0x8e7,0x4(%esp)
 2a7:	00 
 2a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2af:	e8 6c 03 00 00       	call   620 <printf>
      break;
 2b4:	e9 6e fe ff ff       	jmp    127 <ls+0x4f>
 2b9:	8d 76 00             	lea    0x0(%esi),%esi
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
    printf(2, "ls: cannot open %s\n", path);
 2bc:	89 7c 24 08          	mov    %edi,0x8(%esp)
 2c0:	c7 44 24 04 b2 08 00 	movl   $0x8b2,0x4(%esp)
 2c7:	00 
 2c8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 2cf:	e8 4c 03 00 00       	call   620 <printf>
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
}
 2d4:	81 c4 7c 02 00 00    	add    $0x27c,%esp
 2da:	5b                   	pop    %ebx
 2db:	5e                   	pop    %esi
 2dc:	5f                   	pop    %edi
 2dd:	5d                   	pop    %ebp
 2de:	c3                   	ret    
 2df:	90                   	nop
      if(de.inum == 0)
        continue;
      memmove(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      if(stat(buf, &st) < 0){
        printf(1, "ls: cannot stat %s\n", buf);
 2e0:	8d 95 c4 fd ff ff    	lea    -0x23c(%ebp),%edx
 2e6:	89 54 24 08          	mov    %edx,0x8(%esp)
 2ea:	c7 44 24 04 c6 08 00 	movl   $0x8c6,0x4(%esp)
 2f1:	00 
 2f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2f9:	e8 22 03 00 00       	call   620 <printf>
        continue;
 2fe:	e9 d1 fe ff ff       	jmp    1d4 <ls+0xfc>
 303:	90                   	nop
    printf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
    printf(2, "ls: cannot stat %s\n", path);
 304:	89 7c 24 08          	mov    %edi,0x8(%esp)
 308:	c7 44 24 04 c6 08 00 	movl   $0x8c6,0x4(%esp)
 30f:	00 
 310:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 317:	e8 04 03 00 00       	call   620 <printf>
    close(fd);
 31c:	89 1c 24             	mov    %ebx,(%esp)
 31f:	e8 f4 01 00 00       	call   518 <close>
    return;
 324:	e9 06 fe ff ff       	jmp    12f <ls+0x57>
 329:	90                   	nop
 32a:	90                   	nop
 32b:	90                   	nop

0000032c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 32c:	55                   	push   %ebp
 32d:	89 e5                	mov    %esp,%ebp
 32f:	53                   	push   %ebx
 330:	8b 45 08             	mov    0x8(%ebp),%eax
 333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 336:	31 d2                	xor    %edx,%edx
 338:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
 33b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 33e:	42                   	inc    %edx
 33f:	84 c9                	test   %cl,%cl
 341:	75 f5                	jne    338 <strcpy+0xc>
    ;
  return os;
}
 343:	5b                   	pop    %ebx
 344:	5d                   	pop    %ebp
 345:	c3                   	ret    
 346:	66 90                	xchg   %ax,%ax

00000348 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 348:	55                   	push   %ebp
 349:	89 e5                	mov    %esp,%ebp
 34b:	56                   	push   %esi
 34c:	53                   	push   %ebx
 34d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 350:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 353:	8a 01                	mov    (%ecx),%al
 355:	8a 1a                	mov    (%edx),%bl
 357:	84 c0                	test   %al,%al
 359:	74 1d                	je     378 <strcmp+0x30>
 35b:	38 d8                	cmp    %bl,%al
 35d:	74 0c                	je     36b <strcmp+0x23>
 35f:	eb 23                	jmp    384 <strcmp+0x3c>
 361:	8d 76 00             	lea    0x0(%esi),%esi
 364:	41                   	inc    %ecx
 365:	38 d8                	cmp    %bl,%al
 367:	75 1b                	jne    384 <strcmp+0x3c>
    p++, q++;
 369:	89 f2                	mov    %esi,%edx
 36b:	8d 72 01             	lea    0x1(%edx),%esi
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 36e:	8a 41 01             	mov    0x1(%ecx),%al
 371:	8a 5a 01             	mov    0x1(%edx),%bl
 374:	84 c0                	test   %al,%al
 376:	75 ec                	jne    364 <strcmp+0x1c>
 378:	31 c0                	xor    %eax,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 37a:	0f b6 db             	movzbl %bl,%ebx
 37d:	29 d8                	sub    %ebx,%eax
}
 37f:	5b                   	pop    %ebx
 380:	5e                   	pop    %esi
 381:	5d                   	pop    %ebp
 382:	c3                   	ret    
 383:	90                   	nop
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 384:	0f b6 c0             	movzbl %al,%eax
    p++, q++;
  return (uchar)*p - (uchar)*q;
 387:	0f b6 db             	movzbl %bl,%ebx
 38a:	29 d8                	sub    %ebx,%eax
}
 38c:	5b                   	pop    %ebx
 38d:	5e                   	pop    %esi
 38e:	5d                   	pop    %ebp
 38f:	c3                   	ret    

00000390 <strlen>:

uint
strlen(const char *s)
{
 390:	55                   	push   %ebp
 391:	89 e5                	mov    %esp,%ebp
 393:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 396:	80 39 00             	cmpb   $0x0,(%ecx)
 399:	74 10                	je     3ab <strlen+0x1b>
 39b:	31 d2                	xor    %edx,%edx
 39d:	8d 76 00             	lea    0x0(%esi),%esi
 3a0:	42                   	inc    %edx
 3a1:	89 d0                	mov    %edx,%eax
 3a3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 3a7:	75 f7                	jne    3a0 <strlen+0x10>
    ;
  return n;
}
 3a9:	5d                   	pop    %ebp
 3aa:	c3                   	ret    
uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
 3ab:	31 c0                	xor    %eax,%eax
    ;
  return n;
}
 3ad:	5d                   	pop    %ebp
 3ae:	c3                   	ret    
 3af:	90                   	nop

000003b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3b0:	55                   	push   %ebp
 3b1:	89 e5                	mov    %esp,%ebp
 3b3:	57                   	push   %edi
 3b4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 3b7:	89 d7                	mov    %edx,%edi
 3b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bf:	fc                   	cld    
 3c0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 3c2:	89 d0                	mov    %edx,%eax
 3c4:	5f                   	pop    %edi
 3c5:	5d                   	pop    %ebp
 3c6:	c3                   	ret    
 3c7:	90                   	nop

000003c8 <strchr>:

char*
strchr(const char *s, char c)
{
 3c8:	55                   	push   %ebp
 3c9:	89 e5                	mov    %esp,%ebp
 3cb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ce:	8a 4d 0c             	mov    0xc(%ebp),%cl
  for(; *s; s++)
 3d1:	8a 10                	mov    (%eax),%dl
 3d3:	84 d2                	test   %dl,%dl
 3d5:	75 0d                	jne    3e4 <strchr+0x1c>
 3d7:	eb 13                	jmp    3ec <strchr+0x24>
 3d9:	8d 76 00             	lea    0x0(%esi),%esi
 3dc:	8a 50 01             	mov    0x1(%eax),%dl
 3df:	84 d2                	test   %dl,%dl
 3e1:	74 09                	je     3ec <strchr+0x24>
 3e3:	40                   	inc    %eax
    if(*s == c)
 3e4:	38 ca                	cmp    %cl,%dl
 3e6:	75 f4                	jne    3dc <strchr+0x14>
      return (char*)s;
  return 0;
}
 3e8:	5d                   	pop    %ebp
 3e9:	c3                   	ret    
 3ea:	66 90                	xchg   %ax,%ax
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
 3ec:	31 c0                	xor    %eax,%eax
}
 3ee:	5d                   	pop    %ebp
 3ef:	c3                   	ret    

000003f0 <gets>:

char*
gets(char *buf, int max)
{
 3f0:	55                   	push   %ebp
 3f1:	89 e5                	mov    %esp,%ebp
 3f3:	57                   	push   %edi
 3f4:	56                   	push   %esi
 3f5:	53                   	push   %ebx
 3f6:	83 ec 2c             	sub    $0x2c,%esp
 3f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3fc:	31 f6                	xor    %esi,%esi
 3fe:	eb 30                	jmp    430 <gets+0x40>
    cc = read(0, &c, 1);
 400:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 407:	00 
 408:	8d 45 e7             	lea    -0x19(%ebp),%eax
 40b:	89 44 24 04          	mov    %eax,0x4(%esp)
 40f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 416:	e8 ed 00 00 00       	call   508 <read>
    if(cc < 1)
 41b:	85 c0                	test   %eax,%eax
 41d:	7e 19                	jle    438 <gets+0x48>
      break;
    buf[i++] = c;
 41f:	8a 45 e7             	mov    -0x19(%ebp),%al
 422:	88 44 1f ff          	mov    %al,-0x1(%edi,%ebx,1)
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 426:	89 de                	mov    %ebx,%esi
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 428:	3c 0a                	cmp    $0xa,%al
 42a:	74 0c                	je     438 <gets+0x48>
 42c:	3c 0d                	cmp    $0xd,%al
 42e:	74 08                	je     438 <gets+0x48>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 430:	8d 5e 01             	lea    0x1(%esi),%ebx
 433:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 436:	7c c8                	jl     400 <gets+0x10>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 438:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
  return buf;
}
 43c:	89 f8                	mov    %edi,%eax
 43e:	83 c4 2c             	add    $0x2c,%esp
 441:	5b                   	pop    %ebx
 442:	5e                   	pop    %esi
 443:	5f                   	pop    %edi
 444:	5d                   	pop    %ebp
 445:	c3                   	ret    
 446:	66 90                	xchg   %ax,%ax

00000448 <stat>:

int
stat(const char *n, struct stat *st)
{
 448:	55                   	push   %ebp
 449:	89 e5                	mov    %esp,%ebp
 44b:	56                   	push   %esi
 44c:	53                   	push   %ebx
 44d:	83 ec 10             	sub    $0x10,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 450:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 457:	00 
 458:	8b 45 08             	mov    0x8(%ebp),%eax
 45b:	89 04 24             	mov    %eax,(%esp)
 45e:	e8 cd 00 00 00       	call   530 <open>
 463:	89 c3                	mov    %eax,%ebx
  if(fd < 0)
 465:	85 c0                	test   %eax,%eax
 467:	78 23                	js     48c <stat+0x44>
    return -1;
  r = fstat(fd, st);
 469:	8b 45 0c             	mov    0xc(%ebp),%eax
 46c:	89 44 24 04          	mov    %eax,0x4(%esp)
 470:	89 1c 24             	mov    %ebx,(%esp)
 473:	e8 d0 00 00 00       	call   548 <fstat>
 478:	89 c6                	mov    %eax,%esi
  close(fd);
 47a:	89 1c 24             	mov    %ebx,(%esp)
 47d:	e8 96 00 00 00       	call   518 <close>
  return r;
}
 482:	89 f0                	mov    %esi,%eax
 484:	83 c4 10             	add    $0x10,%esp
 487:	5b                   	pop    %ebx
 488:	5e                   	pop    %esi
 489:	5d                   	pop    %ebp
 48a:	c3                   	ret    
 48b:	90                   	nop
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
 48c:	be ff ff ff ff       	mov    $0xffffffff,%esi
 491:	eb ef                	jmp    482 <stat+0x3a>
 493:	90                   	nop

00000494 <atoi>:
  return r;
}

int
atoi(const char *s)
{
 494:	55                   	push   %ebp
 495:	89 e5                	mov    %esp,%ebp
 497:	53                   	push   %ebx
 498:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 49b:	8a 11                	mov    (%ecx),%dl
 49d:	8d 42 d0             	lea    -0x30(%edx),%eax
 4a0:	3c 09                	cmp    $0x9,%al
 4a2:	b8 00 00 00 00       	mov    $0x0,%eax
 4a7:	77 18                	ja     4c1 <atoi+0x2d>
 4a9:	8d 76 00             	lea    0x0(%esi),%esi
    n = n*10 + *s++ - '0';
 4ac:	8d 04 80             	lea    (%eax,%eax,4),%eax
 4af:	0f be d2             	movsbl %dl,%edx
 4b2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
 4b6:	41                   	inc    %ecx
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4b7:	8a 11                	mov    (%ecx),%dl
 4b9:	8d 5a d0             	lea    -0x30(%edx),%ebx
 4bc:	80 fb 09             	cmp    $0x9,%bl
 4bf:	76 eb                	jbe    4ac <atoi+0x18>
    n = n*10 + *s++ - '0';
  return n;
}
 4c1:	5b                   	pop    %ebx
 4c2:	5d                   	pop    %ebp
 4c3:	c3                   	ret    

000004c4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4c4:	55                   	push   %ebp
 4c5:	89 e5                	mov    %esp,%ebp
 4c7:	56                   	push   %esi
 4c8:	53                   	push   %ebx
 4c9:	8b 45 08             	mov    0x8(%ebp),%eax
 4cc:	8b 75 0c             	mov    0xc(%ebp),%esi
 4cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4d2:	85 db                	test   %ebx,%ebx
 4d4:	7e 0d                	jle    4e3 <memmove+0x1f>
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
 4d6:	31 d2                	xor    %edx,%edx
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    *dst++ = *src++;
 4d8:	8a 0c 16             	mov    (%esi,%edx,1),%cl
 4db:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 4de:	42                   	inc    %edx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4df:	39 da                	cmp    %ebx,%edx
 4e1:	75 f5                	jne    4d8 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
}
 4e3:	5b                   	pop    %ebx
 4e4:	5e                   	pop    %esi
 4e5:	5d                   	pop    %ebp
 4e6:	c3                   	ret    
 4e7:	90                   	nop

000004e8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4e8:	b8 01 00 00 00       	mov    $0x1,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <exit>:
SYSCALL(exit)
 4f0:	b8 02 00 00 00       	mov    $0x2,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <wait>:
SYSCALL(wait)
 4f8:	b8 03 00 00 00       	mov    $0x3,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <pipe>:
SYSCALL(pipe)
 500:	b8 04 00 00 00       	mov    $0x4,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <read>:
SYSCALL(read)
 508:	b8 05 00 00 00       	mov    $0x5,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <write>:
SYSCALL(write)
 510:	b8 10 00 00 00       	mov    $0x10,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <close>:
SYSCALL(close)
 518:	b8 15 00 00 00       	mov    $0x15,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <kill>:
SYSCALL(kill)
 520:	b8 06 00 00 00       	mov    $0x6,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <exec>:
SYSCALL(exec)
 528:	b8 07 00 00 00       	mov    $0x7,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <open>:
SYSCALL(open)
 530:	b8 0f 00 00 00       	mov    $0xf,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <mknod>:
SYSCALL(mknod)
 538:	b8 11 00 00 00       	mov    $0x11,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <unlink>:
SYSCALL(unlink)
 540:	b8 12 00 00 00       	mov    $0x12,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <fstat>:
SYSCALL(fstat)
 548:	b8 08 00 00 00       	mov    $0x8,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <link>:
SYSCALL(link)
 550:	b8 13 00 00 00       	mov    $0x13,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <mkdir>:
SYSCALL(mkdir)
 558:	b8 14 00 00 00       	mov    $0x14,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <chdir>:
SYSCALL(chdir)
 560:	b8 09 00 00 00       	mov    $0x9,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <dup>:
SYSCALL(dup)
 568:	b8 0a 00 00 00       	mov    $0xa,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <getpid>:
SYSCALL(getpid)
 570:	b8 0b 00 00 00       	mov    $0xb,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <sbrk>:
SYSCALL(sbrk)
 578:	b8 0c 00 00 00       	mov    $0xc,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <sleep>:
SYSCALL(sleep)
 580:	b8 0d 00 00 00       	mov    $0xd,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <uptime>:
SYSCALL(uptime)
 588:	b8 0e 00 00 00       	mov    $0xe,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 590:	55                   	push   %ebp
 591:	89 e5                	mov    %esp,%ebp
 593:	83 ec 28             	sub    $0x28,%esp
 596:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 599:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5a0:	00 
 5a1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 5a4:	89 54 24 04          	mov    %edx,0x4(%esp)
 5a8:	89 04 24             	mov    %eax,(%esp)
 5ab:	e8 60 ff ff ff       	call   510 <write>
}
 5b0:	c9                   	leave  
 5b1:	c3                   	ret    
 5b2:	66 90                	xchg   %ax,%ax

000005b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5b4:	55                   	push   %ebp
 5b5:	89 e5                	mov    %esp,%ebp
 5b7:	57                   	push   %edi
 5b8:	56                   	push   %esi
 5b9:	53                   	push   %ebx
 5ba:	83 ec 1c             	sub    $0x1c,%esp
 5bd:	89 c6                	mov    %eax,%esi
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 5bf:	89 d0                	mov    %edx,%eax
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
 5c4:	85 db                	test   %ebx,%ebx
 5c6:	74 04                	je     5cc <printint+0x18>
 5c8:	85 d2                	test   %edx,%edx
 5ca:	78 4a                	js     616 <printint+0x62>
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5cc:	31 ff                	xor    %edi,%edi
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5ce:	31 db                	xor    %ebx,%ebx
 5d0:	eb 04                	jmp    5d6 <printint+0x22>
 5d2:	66 90                	xchg   %ax,%ax
  do{
    buf[i++] = digits[x % base];
 5d4:	89 d3                	mov    %edx,%ebx
 5d6:	31 d2                	xor    %edx,%edx
 5d8:	f7 f1                	div    %ecx
 5da:	8a 92 03 09 00 00    	mov    0x903(%edx),%dl
 5e0:	88 54 1d d8          	mov    %dl,-0x28(%ebp,%ebx,1)
 5e4:	8d 53 01             	lea    0x1(%ebx),%edx
  }while((x /= base) != 0);
 5e7:	85 c0                	test   %eax,%eax
 5e9:	75 e9                	jne    5d4 <printint+0x20>
  if(neg)
 5eb:	85 ff                	test   %edi,%edi
 5ed:	74 08                	je     5f7 <printint+0x43>
    buf[i++] = '-';
 5ef:	c6 44 15 d8 2d       	movb   $0x2d,-0x28(%ebp,%edx,1)
 5f4:	8d 53 02             	lea    0x2(%ebx),%edx

  while(--i >= 0)
 5f7:	8d 5a ff             	lea    -0x1(%edx),%ebx
 5fa:	66 90                	xchg   %ax,%ax
    putc(fd, buf[i]);
 5fc:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 601:	89 f0                	mov    %esi,%eax
 603:	e8 88 ff ff ff       	call   590 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 608:	4b                   	dec    %ebx
 609:	83 fb ff             	cmp    $0xffffffff,%ebx
 60c:	75 ee                	jne    5fc <printint+0x48>
    putc(fd, buf[i]);
}
 60e:	83 c4 1c             	add    $0x1c,%esp
 611:	5b                   	pop    %ebx
 612:	5e                   	pop    %esi
 613:	5f                   	pop    %edi
 614:	5d                   	pop    %ebp
 615:	c3                   	ret    
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 616:	f7 d8                	neg    %eax
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
 618:	bf 01 00 00 00       	mov    $0x1,%edi
    x = -xx;
 61d:	eb af                	jmp    5ce <printint+0x1a>
 61f:	90                   	nop

00000620 <printf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 620:	55                   	push   %ebp
 621:	89 e5                	mov    %esp,%ebp
 623:	57                   	push   %edi
 624:	56                   	push   %esi
 625:	53                   	push   %ebx
 626:	83 ec 2c             	sub    $0x2c,%esp
 629:	8b 7d 08             	mov    0x8(%ebp),%edi
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 62c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 62f:	8a 0b                	mov    (%ebx),%cl
 631:	84 c9                	test   %cl,%cl
 633:	74 7b                	je     6b0 <printf+0x90>
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 635:	8d 45 10             	lea    0x10(%ebp),%eax
 638:	89 45 e4             	mov    %eax,-0x1c(%ebp)
{
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 63b:	31 f6                	xor    %esi,%esi
 63d:	eb 17                	jmp    656 <printf+0x36>
 63f:	90                   	nop
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
 640:	83 f9 25             	cmp    $0x25,%ecx
 643:	74 73                	je     6b8 <printf+0x98>
        state = '%';
      } else {
        putc(fd, c);
 645:	0f be d1             	movsbl %cl,%edx
 648:	89 f8                	mov    %edi,%eax
 64a:	e8 41 ff ff ff       	call   590 <putc>
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 64f:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 650:	8a 0b                	mov    (%ebx),%cl
 652:	84 c9                	test   %cl,%cl
 654:	74 5a                	je     6b0 <printf+0x90>
    c = fmt[i] & 0xff;
 656:	0f b6 c9             	movzbl %cl,%ecx
    if(state == 0){
 659:	85 f6                	test   %esi,%esi
 65b:	74 e3                	je     640 <printf+0x20>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 65d:	83 fe 25             	cmp    $0x25,%esi
 660:	75 ed                	jne    64f <printf+0x2f>
      if(c == 'd'){
 662:	83 f9 64             	cmp    $0x64,%ecx
 665:	0f 84 c1 00 00 00    	je     72c <printf+0x10c>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 66b:	83 f9 78             	cmp    $0x78,%ecx
 66e:	74 50                	je     6c0 <printf+0xa0>
 670:	83 f9 70             	cmp    $0x70,%ecx
 673:	74 4b                	je     6c0 <printf+0xa0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 675:	83 f9 73             	cmp    $0x73,%ecx
 678:	74 6a                	je     6e4 <printf+0xc4>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 67a:	83 f9 63             	cmp    $0x63,%ecx
 67d:	0f 84 91 00 00 00    	je     714 <printf+0xf4>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
        putc(fd, c);
 683:	ba 25 00 00 00       	mov    $0x25,%edx
 688:	89 f8                	mov    %edi,%eax
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 68a:	83 f9 25             	cmp    $0x25,%ecx
 68d:	74 10                	je     69f <printf+0x7f>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 68f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
 692:	e8 f9 fe ff ff       	call   590 <putc>
        putc(fd, c);
 697:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 69a:	0f be d1             	movsbl %cl,%edx
 69d:	89 f8                	mov    %edi,%eax
 69f:	e8 ec fe ff ff       	call   590 <putc>
      }
      state = 0;
 6a4:	31 f6                	xor    %esi,%esi
      } else if(c == '%'){
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 6a6:	43                   	inc    %ebx
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6a7:	8a 0b                	mov    (%ebx),%cl
 6a9:	84 c9                	test   %cl,%cl
 6ab:	75 a9                	jne    656 <printf+0x36>
 6ad:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b0:	83 c4 2c             	add    $0x2c,%esp
 6b3:	5b                   	pop    %ebx
 6b4:	5e                   	pop    %esi
 6b5:	5f                   	pop    %edi
 6b6:	5d                   	pop    %ebp
 6b7:	c3                   	ret    
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 6b8:	be 25 00 00 00       	mov    $0x25,%esi
 6bd:	eb 90                	jmp    64f <printf+0x2f>
 6bf:	90                   	nop
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
 6c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 6c7:	b9 10 00 00 00       	mov    $0x10,%ecx
 6cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6cf:	8b 10                	mov    (%eax),%edx
 6d1:	89 f8                	mov    %edi,%eax
 6d3:	e8 dc fe ff ff       	call   5b4 <printint>
        ap++;
 6d8:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6dc:	31 f6                	xor    %esi,%esi
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
        printint(fd, *ap, 16, 0);
        ap++;
 6de:	e9 6c ff ff ff       	jmp    64f <printf+0x2f>
 6e3:	90                   	nop
      } else if(c == 's'){
        s = (char*)*ap;
 6e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e7:	8b 30                	mov    (%eax),%esi
        ap++;
 6e9:	83 c0 04             	add    $0x4,%eax
 6ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 6ef:	85 f6                	test   %esi,%esi
 6f1:	74 5a                	je     74d <printf+0x12d>
          s = "(null)";
        while(*s != 0){
 6f3:	8a 16                	mov    (%esi),%dl
 6f5:	84 d2                	test   %dl,%dl
 6f7:	74 14                	je     70d <printf+0xed>
 6f9:	8d 76 00             	lea    0x0(%esi),%esi
          putc(fd, *s);
 6fc:	0f be d2             	movsbl %dl,%edx
 6ff:	89 f8                	mov    %edi,%eax
 701:	e8 8a fe ff ff       	call   590 <putc>
          s++;
 706:	46                   	inc    %esi
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 707:	8a 16                	mov    (%esi),%dl
 709:	84 d2                	test   %dl,%dl
 70b:	75 ef                	jne    6fc <printf+0xdc>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 70d:	31 f6                	xor    %esi,%esi
 70f:	e9 3b ff ff ff       	jmp    64f <printf+0x2f>
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
        putc(fd, *ap);
 714:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 717:	0f be 10             	movsbl (%eax),%edx
 71a:	89 f8                	mov    %edi,%eax
 71c:	e8 6f fe ff ff       	call   590 <putc>
        ap++;
 721:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 725:	31 f6                	xor    %esi,%esi
 727:	e9 23 ff ff ff       	jmp    64f <printf+0x2f>
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
      if(c == 'd'){
        printint(fd, *ap, 10, 1);
 72c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 733:	b1 0a                	mov    $0xa,%cl
 735:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 738:	8b 10                	mov    (%eax),%edx
 73a:	89 f8                	mov    %edi,%eax
 73c:	e8 73 fe ff ff       	call   5b4 <printint>
        ap++;
 741:	83 45 e4 04          	addl   $0x4,-0x1c(%ebp)
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 745:	66 31 f6             	xor    %si,%si
 748:	e9 02 ff ff ff       	jmp    64f <printf+0x2f>
        ap++;
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
 74d:	be fc 08 00 00       	mov    $0x8fc,%esi
 752:	eb 9f                	jmp    6f3 <printf+0xd3>

00000754 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 754:	55                   	push   %ebp
 755:	89 e5                	mov    %esp,%ebp
 757:	57                   	push   %edi
 758:	56                   	push   %esi
 759:	53                   	push   %ebx
 75a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 75d:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 760:	a1 30 0c 00 00       	mov    0xc30,%eax
 765:	8d 76 00             	lea    0x0(%esi),%esi
 768:	8b 10                	mov    (%eax),%edx
 76a:	39 c8                	cmp    %ecx,%eax
 76c:	73 04                	jae    772 <free+0x1e>
 76e:	39 d1                	cmp    %edx,%ecx
 770:	72 12                	jb     784 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 772:	39 d0                	cmp    %edx,%eax
 774:	72 08                	jb     77e <free+0x2a>
 776:	39 c8                	cmp    %ecx,%eax
 778:	72 0a                	jb     784 <free+0x30>
 77a:	39 d1                	cmp    %edx,%ecx
 77c:	72 06                	jb     784 <free+0x30>
static Header base;
static Header *freep;

void
free(void *ap)
{
 77e:	89 d0                	mov    %edx,%eax
 780:	eb e6                	jmp    768 <free+0x14>
 782:	66 90                	xchg   %ax,%ax

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 784:	8b 73 fc             	mov    -0x4(%ebx),%esi
 787:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 78a:	39 d7                	cmp    %edx,%edi
 78c:	74 19                	je     7a7 <free+0x53>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 78e:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 791:	8b 50 04             	mov    0x4(%eax),%edx
 794:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 797:	39 f1                	cmp    %esi,%ecx
 799:	74 23                	je     7be <free+0x6a>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 79b:	89 08                	mov    %ecx,(%eax)
  freep = p;
 79d:	a3 30 0c 00 00       	mov    %eax,0xc30
}
 7a2:	5b                   	pop    %ebx
 7a3:	5e                   	pop    %esi
 7a4:	5f                   	pop    %edi
 7a5:	5d                   	pop    %ebp
 7a6:	c3                   	ret    
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7a7:	03 72 04             	add    0x4(%edx),%esi
 7aa:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ad:	8b 10                	mov    (%eax),%edx
 7af:	8b 12                	mov    (%edx),%edx
 7b1:	89 53 f8             	mov    %edx,-0x8(%ebx)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 7b4:	8b 50 04             	mov    0x4(%eax),%edx
 7b7:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 7ba:	39 f1                	cmp    %esi,%ecx
 7bc:	75 dd                	jne    79b <free+0x47>
    p->s.size += bp->s.size;
 7be:	03 53 fc             	add    -0x4(%ebx),%edx
 7c1:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7c4:	8b 53 f8             	mov    -0x8(%ebx),%edx
 7c7:	89 10                	mov    %edx,(%eax)
  } else
    p->s.ptr = bp;
  freep = p;
 7c9:	a3 30 0c 00 00       	mov    %eax,0xc30
}
 7ce:	5b                   	pop    %ebx
 7cf:	5e                   	pop    %esi
 7d0:	5f                   	pop    %edi
 7d1:	5d                   	pop    %ebp
 7d2:	c3                   	ret    
 7d3:	90                   	nop

000007d4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7d4:	55                   	push   %ebp
 7d5:	89 e5                	mov    %esp,%ebp
 7d7:	57                   	push   %edi
 7d8:	56                   	push   %esi
 7d9:	53                   	push   %ebx
 7da:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
 7e0:	83 c3 07             	add    $0x7,%ebx
 7e3:	c1 eb 03             	shr    $0x3,%ebx
 7e6:	43                   	inc    %ebx
  if((prevp = freep) == 0){
 7e7:	8b 0d 30 0c 00 00    	mov    0xc30,%ecx
 7ed:	85 c9                	test   %ecx,%ecx
 7ef:	0f 84 95 00 00 00    	je     88a <malloc+0xb6>
 7f5:	8b 01                	mov    (%ecx),%eax
 7f7:	8b 50 04             	mov    0x4(%eax),%edx
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
 7fa:	39 da                	cmp    %ebx,%edx
 7fc:	73 66                	jae    864 <malloc+0x90>
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
 7fe:	8d 3c dd 00 00 00 00 	lea    0x0(,%ebx,8),%edi
 805:	eb 0c                	jmp    813 <malloc+0x3f>
 807:	90                   	nop
    }
    if(p == freep)
 808:	89 c1                	mov    %eax,%ecx
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80a:	8b 01                	mov    (%ecx),%eax
    if(p->s.size >= nunits){
 80c:	8b 50 04             	mov    0x4(%eax),%edx
 80f:	39 d3                	cmp    %edx,%ebx
 811:	76 51                	jbe    864 <malloc+0x90>
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 813:	3b 05 30 0c 00 00    	cmp    0xc30,%eax
 819:	75 ed                	jne    808 <malloc+0x34>
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 81b:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
 821:	76 35                	jbe    858 <malloc+0x84>
 823:	89 f8                	mov    %edi,%eax
 825:	89 de                	mov    %ebx,%esi
    nu = 4096;
  p = sbrk(nu * sizeof(Header));
 827:	89 04 24             	mov    %eax,(%esp)
 82a:	e8 49 fd ff ff       	call   578 <sbrk>
  if(p == (char*)-1)
 82f:	83 f8 ff             	cmp    $0xffffffff,%eax
 832:	74 18                	je     84c <malloc+0x78>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 834:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 837:	83 c0 08             	add    $0x8,%eax
 83a:	89 04 24             	mov    %eax,(%esp)
 83d:	e8 12 ff ff ff       	call   754 <free>
  return freep;
 842:	8b 0d 30 0c 00 00    	mov    0xc30,%ecx
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
 848:	85 c9                	test   %ecx,%ecx
 84a:	75 be                	jne    80a <malloc+0x36>
        return 0;
 84c:	31 c0                	xor    %eax,%eax
  }
}
 84e:	83 c4 1c             	add    $0x1c,%esp
 851:	5b                   	pop    %ebx
 852:	5e                   	pop    %esi
 853:	5f                   	pop    %edi
 854:	5d                   	pop    %ebp
 855:	c3                   	ret    
 856:	66 90                	xchg   %ax,%ax
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
 858:	b8 00 80 00 00       	mov    $0x8000,%eax
    nu = 4096;
 85d:	be 00 10 00 00       	mov    $0x1000,%esi
 862:	eb c3                	jmp    827 <malloc+0x53>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 864:	39 d3                	cmp    %edx,%ebx
 866:	74 1c                	je     884 <malloc+0xb0>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 868:	29 da                	sub    %ebx,%edx
 86a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 86d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 870:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 873:	89 0d 30 0c 00 00    	mov    %ecx,0xc30
      return (void*)(p + 1);
 879:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 87c:	83 c4 1c             	add    $0x1c,%esp
 87f:	5b                   	pop    %ebx
 880:	5e                   	pop    %esi
 881:	5f                   	pop    %edi
 882:	5d                   	pop    %ebp
 883:	c3                   	ret    
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
 884:	8b 10                	mov    (%eax),%edx
 886:	89 11                	mov    %edx,(%ecx)
 888:	eb e9                	jmp    873 <malloc+0x9f>
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
 88a:	c7 05 30 0c 00 00 34 	movl   $0xc34,0xc30
 891:	0c 00 00 
 894:	c7 05 34 0c 00 00 34 	movl   $0xc34,0xc34
 89b:	0c 00 00 
    base.s.size = 0;
 89e:	c7 05 38 0c 00 00 00 	movl   $0x0,0xc38
 8a5:	00 00 00 
 8a8:	b8 34 0c 00 00       	mov    $0xc34,%eax
 8ad:	e9 4c ff ff ff       	jmp    7fe <malloc+0x2a>
