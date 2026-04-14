#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <string.h>
 typedef int (*op_function)(int, int);
int main(){
    char op[6];
    int num1,num2;
    
    char tracker[6]="";
    void *handle=NULL;
    while(scanf("%5s %d %d",op,&num1,&num2)==3){
        if(strcmp(op,tracker)!=0){
            if(handle!=NULL){
                dlclose(handle);
                handle=NULL;
            }
            char libraryname[32];
            snprintf(libraryname, sizeof(libraryname), "./lib%s.so", op);
            handle=dlopen(libraryname, RTLD_LAZY);
            if(!handle){
                fprintf(stderr, "Error Loading library: %s\n",dlerror());
                tracker[0]='\0';
                continue;
            }
            strcpy(tracker,op);

        }
        dlerror();
       op_function func = (op_function) dlsym(handle, op);
char *error = dlerror();
if(error!=NULL){
    fprintf(stderr,"Error finding function: %s\n",error);
    continue;
}
int result=func(num1,num2);
printf("%d\n",result);
    }
if(handle!=NULL){
    dlclose(handle);
}

    return 0;
}