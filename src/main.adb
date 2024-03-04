with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;

procedure Main is

   can_stop : Boolean := False;
   pragma Atomic (can_stop);

   numberOfthreads : Integer := 10;
   type RandRange is range 1 .. 20;

   task type stop_thread;
   task type child_thread is
      entry start (index : Integer);
   end child_thread;

   task body stop_thread is
   begin
      delay 2.0;
      can_stop := True;
   end stop_thread;

   task body child_thread is

      package Rand_Int is new Ada.Numerics.Discrete_Random (RandRange);
      use Rand_Int;
      Rand : Generator;

      sum     : Long_Long_Integer := 0;
      counter : Long_Integer      := 0;
      step    : Long_Long_Integer := 0;
      index   : Integer           := 0;
   begin
      accept start (index : Integer) do
         child_thread.step  := step;
         child_thread.index := index;
      end start;
      Reset (Rand);
      step := Long_Long_Integer (Random (Rand));
      loop
         counter := counter + 1;
         sum     := sum + step;
         exit when can_stop;
      end loop;
      Ada.Text_IO.Put_Line
        ("Thread index: " & index'Img & " Sum: " & sum'Img & " Count: " &
         counter'Img & " step: " & step'Img);

   end child_thread;

   type thread_array is array (1 .. numberOfthreads) of child_thread;

   MyArray : thread_array;
   start   : stop_thread;

begin
   for I in MyArray'Range loop
      MyArray (I).start (I);
   end loop;

end Main;

