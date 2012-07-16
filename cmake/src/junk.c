#include <stdio.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

void maoi_test(int a, int b) {
  lua_State *L = NULL;
  printf("%d %d", a, b);
  L = lua_open();
  luaL_openlibs(L);
  lua_gettop(L);
}

int main(void) {
  maoi_test(1, 2);
  return 0;
}

