#!/usr/bin/env perl

sub random3digits {
   local ($out, $aa, $bb, $cc);
   $aa = int(rand(9));
   $bb = int(rand(9));
   $cc = int(rand(9));
   $out = "$aa$bb$cc";
   return "$out";
}

sub gfunction {
   local ($chr, $fill, $out, $num2);
   local ($s = $_[0]);
   local ($t = $_[1]);
   local @a = split(//,$s);
   local $reserve = $t;
   foreach $chr (@a) {
      $twobits = ($t % 4);
      $t = $t / 4;
      if ($t < 1) { $t = $reserve; }     #DONT use $t == 1 !!
      $fill = &random3digits;
      
			if ($twobits == 0) { 
				$fill = "";
      } else {
      	$fill = substr($fill,0,$twobits);
      }

   		$num2 = (unpack("c",$chr) - 32);
   		$num2 = (length $num2 == 1) ? "0$num2" : "$num2";
   		$out .= "$fill";
   		$out .= "$num2";
   }
   
	return "$out";
}

local $x;
$x = &gfunction($ENV{"AICC_STRING"}, $ENV{"AICC_ENC_KEY"});
print "$x";