#ifdef __cplusplus  
	extern "C"
	{
		void printk(const char* format, ...);
		void test_C_plus_plus(void);
	}
#endif  

void test_C_plus_plus(void)
{
	printk("it is made by C++.");
}