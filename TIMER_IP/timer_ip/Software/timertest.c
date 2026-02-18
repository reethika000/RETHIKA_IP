#define TIMER_BASE   0x20001000

#define TIMER_CTRL   (*(volatile unsigned int *)(TIMER_BASE + 0x00))
#define TIMER_LOAD   (*(volatile unsigned int *)(TIMER_BASE + 0x04))
#define TIMER_VALUE  (*(volatile unsigned int *)(TIMER_BASE + 0x08))
#define TIMER_STAT   (*(volatile unsigned int *)(TIMER_BASE + 0x0C))

// Bit definitions
#define CTRL_EN      (1 << 0)
#define CTRL_MODE    (1 << 1)   // 0 = one-shot, 1 = periodic

#define STAT_TIMEOUT (1 << 0)

// For simulation use small value
#define TEST_COUNT   10

void delay_loop()
{
    for (volatile int i = 0; i < 1000; i++);
}

int main(void)
{
   
    //  ONE-SHOT MODE TEST
  
    
    TIMER_LOAD = TEST_COUNT;

    // Enable timer in ONE-SHOT (EN=1, MODE=0)
    TIMER_CTRL = CTRL_EN;

    // Wait for timeout
    while ((TIMER_STAT & STAT_TIMEOUT) == 0)
        ;

    

    // Clear TIMEOUT using W1C
    TIMER_STAT = STAT_TIMEOUT;

    // Small delay to prove it does NOT restart
    delay_loop();


    // PERIODIC MODE TEST
   

    TIMER_LOAD = TEST_COUNT;

    // Enable timer in PERIODIC mode
    TIMER_CTRL = CTRL_EN | CTRL_MODE;

    while (1)
    {
        // Wait for timeout
        while ((TIMER_STAT & STAT_TIMEOUT) == 0)
            ;

        // Clear sticky timeout
        TIMER_STAT = STAT_TIMEOUT;

        
    }

    return 0;
}
