#!/usr/bin/perl  

if (@ARGV != 1) {
     print "输入参数错误！ usage: <times> \n";
     exit(0);
}
######parmeter######
my $Freq=shift @ARGV;
my %hash = (
  "Cpu" => "top -bn 1|grep Cpu",
  "Mem" => "free |grep Mem",
 # "Swap" => "top -n 1 |grep Swap",
  "iostat" => "iostat -d 1 1 |grep sd",
);
######command#######
&getsysstatus;

######cycle forever,you can use kill or ctrl + c stop it #######
sub getsysstatus{
  my $pidCount = 4;
  my $flags = `date +%Y%m%d%H`;
  chomp $flags;
  while(($key,$value) = each %hash){
    $pid = fork();
    if($pid == 0){
      while(1){
        my $filedate = `date +%Y%m%d%H`;
	chomp $filedate;
        my $FullFileName = $key."_"."$filedate.log";
	if($flags != $filedate){
	  if($key eq "Cpu"){
	    &Cpu ($key."_"."$flags.log");
	    $flags = $filedate;
	  }
	  elsif ($key eq "Mem"){
	    &Mem ($key."_"."$flags.log");
	    $flags = $filedate;
	  }
	  elsif($key eq "iostat"){
	    &Io ($key."_"."$flags.log");
	    $flags = $filedate;
	  }
	}
        sleep $Freq -1;
        system("$value >> $FullFileName");
     }
     exit(0);
   }else{
     next;
   }
 }
 for(;$pidCount>0;$pidCount--){
   waitpid(-1,0);
 }
}

#############count avg####
sub Cpu{
  my $CpuAvg;
  my $CpuHighestValue;
  my $Count = 0;
  my $date = `date +%Y%m%d`;
  chomp $date;
  my $Cpu = "Cpu";
  open CPULOG,"$_[0]"or die "Can,t open cpulog";
  open RESULT,">>result_$date.log" or die "Can,t open result log";
  while(<CPULOG>){
    chomp;
    $Count++;
    if(/.* (\d+.\d+)\%sy/){
      if($1 > $CpuHighestValue){
        $CpuHighestValue = $1;
      }
      $CpuAvg += $1;
    }
    }
    $CpuAvg = $CpuAvg/$Count;
    print RESULT "===================CPU================="."\n";
    print RESULT "      Avg    Highest    "."\n";
    print RESULT "      $CpuAvg    $CpuHighestValue    "."\n"; 
    close(CPULOG);
    close(RESULT);
}

sub Mem{
  my $MemAvg,$MemHighestValue = 0,$Count;
  my $Mem = "Mem";
  my $date = `date +%Y%m%d`;
  chomp $date;
  open MEMLOG,"$_[0]" or die "Can,t open memlog";
  open RESULT,">>result_$date.log" or die "Can,t open result log";
  while(<MEMLOG>){
    $Count++;
    chomp;
    if(/(\d+).* (\d+).* (\d+).* (\d+).* (\d+).* (\d+)/){
      $MemAvg += ($2-$3-$5-$6)/$1;
      if(($2-$3-$5-$6)/$1 > $MemHighestValue) {
        $MemHighestValue = ($2-$3-$5-$6)/$1;
      }
    }
    }
    $MemAvg = $MemAvg/$Count;
    print RESULT "===================Mem================="."\n";
    print RESULT "      Avg    Highest    "."\n";
    print RESULT "      $MemAvg    $MemHighestValue    "."\n";
    close(MEMLOG);
    close(RESULT);

}

sub Io{
  my $IoHighestValue = 0,$Count,$IoAvg;
  my $Io = "Io";
  my $date = `date +%Y%m%d`;
  chomp $date;
  open IOLOG,"$_[0]" or die "Can,t open iolog";
  open RESULT,">>result_$date.log" or die "Can,t open result log";
  while(<IOLOG>){
    $Count++;
    chomp;
    if(/.* (\d+\.\d+).* (\d+\.\d+) .* (\d+\.\d+)/){
      $IoAvg += $2+$3;
      if(($2+$3) > $IoHighestValue){
        $IoHighestValue = $2+$3;
      }
    }
  } 
  $IoAvg = $IoAvg/$Count;
   print RESULT "===================IO================="."\n";
   print RESULT "      Avg    Highest    "."\n";
   print RESULT "      $IoAvg    $IoHighestValue    "."\n";
   close(IOLOG);
   close(RESULT);
}
