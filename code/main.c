
#define GFX_BACKEND_GL 1
#define OS_FEATURE_GFX 1
#define PROFILE_ENABLED 1



// h
#include "base/base_inc.h"
#include "os/os_inc.h"
#include "render/render_inc.h"
#include "font/font_inc.h"
#include "formats/formats_inc.h"
#include "draw/draw.h"
#include "ui/ui_inc.h"
#include "profiler/profiler.h"


// c
#include "base/base_inc.c"
#include "os/os_inc.c"
#include "font/font_inc.c"
#include "formats/formats_inc.c"
#include "render/render_inc.c"
#include "draw/draw.c"
#include "ui/ui_inc.c"
#include "profiler/profiler.c"


void
entry_point(CmdLine cmdline)
{
  
 OS_Handle window  = os_window_open(v2s16(1280, 760), StrLit("window"));
 R_Handle window_r = r_window_equip(window);
 os_window_first_paint(window);

 U64 prev_time = os_time_microseconds();
 for(B32 quit = 0; quit == 0;)
 {
  Temp scratch = scratch_begin(0);
  F32 dt;
  {
   U64 curr_time = os_time_microseconds();
   U64 delta = curr_time - prev_time;
   dt = delta * 0.001f * 0.001f;
   prev_time = curr_time;
  }
  
  OS_EventList events;
  {
   events = os_get_events(scratch.arena);
  }

  {
   r_begin_frame();
   r_window_start(window_r);
   D_Bucket* bucket = d_bucket_alloc(scratch.arena);



   ui_begin_build(window, events, dt);
   ui_end_build();
   ui_draw(bucket);

   d_submit(window_r, bucket);

   r_window_finish(window_r);
   r_end_frame();
  }

  for(OS_Event * event = events.first;
   event != 0;
   event = event->next)
  {
   if(event->kind == OS_EventKind_WindowClose)
   {
    quit = true;
    break;
   }
  }
  if(os_key_press(events, OS_Key_Esc))
  {
   quit = true;
  }

  scratch_end(scratch);

 }
}


