var m, n, r, q;
procedure gcd;
    begin
        while r#0  do 
             begin
                 q := m / n;
                  r := m - q * n;
                 m := n;
                 n := r;
             end
   end;
begin
     read(m);
     read(n);
     r:=1;
     call gcd;
     write(m);
end.