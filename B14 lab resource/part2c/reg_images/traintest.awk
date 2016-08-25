BEGIN {
	FS="/"
};

{
	if (NR % 2)
		fn="train.txt";
	else
		fn="test.txt";

	if ($1=="smiling")
		cls=1;
	else
		cls=0;

	print $0,cls >fn
}
