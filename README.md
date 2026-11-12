This project builds off of Lab3_embedded, where the goal this time is to:

    Rebuild the scheduler to introduce OS priority (0-255) using Multi-Level Feedback Queue (MLFQ)
    Restructure existing hard-deadline periodic event tasks to signal high priority main threads with hardware timers
    Introduce an edge-triggered interrupt service routine that signals a main thread to handle GPIO
    Ensure no hanging edge-trigger events by disabling port interrupts and re-enabling during a stable period

os.c:

    Slight TCB modifications, increasing the amount of main threads from 6 to 8, and having a priority field
    Update scheduler:
    - Always consider all threads, even the current running thread
    - Automatically consider and start from the next thread from the running thread
    - Starting from lowest priority level choice, find highest priority non-blocked/non-sleeping thread
    - Threads found of the same highest found priority will be treated round-robin style
    Restructure hardware timers to hold semaphores and signal associated main thread in ISR handler at the end of period 
    The edge-trigger setup and handling:
      Setup initialization for edge-trigger for a digital input GPIO port pin as a falling-edge event:
      - Be sure to clear RIS flags (indicate need for ISR) for the port pin
      - Be sure to arm interrupts for the port pin
      - Set system priority (0-7) for the port based on user preference
      Set edge-trigger ISR handler to:
      - Clear RIS flag (indicates need for ISR)
      - Signal associated high priority thread
      - Disarm port interrupts to prevent ISR calls for hanging edge-triggers
      - Suspend to force reschedule (high chance to call signaled high priority thread)
      The old hard-deadline periodic task as a high priority main thread:
      - Waits for edge-trigger signal and reschedule
      - Calls sleep for a duration to reach de-bounced stable period to extract port input
      - After thread operation rearm interrupts for port pin and reset RIS flag

osasm.s:

    Remains the same from Lab2_Embedded

Overall this is a very cool project, getting closer to the hardware from last time. 
We know we can use hardware timers to execute periodic tasks but why not instead signal main threads for the scheduler to deal with? 
Also if we were worried about periodic event producer tasks meeting hard deadlines, lets setup the scheduler to where those hard deadlines are treated with high priority!
With every call to the scheduler all threads are considered, and available high priority threads are scheduled quicker and more often than low-priority, 
reducing jitter while handing decision making to the operating system instead of the hardware timers.
Last but not least one of the most interesting portions of this project, the edge-triggered ISR. In the project, I configured a button as input that, when pressed, would switch the display of the
on-board LCD and sound a buzzer. Lastly to ensure microseconds of physical overhang wasn't treated as a misfired interrupt, I de-bounced the edge-triggered I/O for correctness.  

Although the action of the device is small, this project gives insight for setting up sensors and switches for real-time events. 
This in combination with the updated scheduler for integrating hard-deadline tasks and the existing FIFO buffer for storing data for producers/consumers for constant data flow!

Testing consisted of using Keil uVisions debugger and watch window as well as my own logic analyzer to track pin activity.
