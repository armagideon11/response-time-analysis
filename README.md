# response-time-analysis
Perl project to analyze tomcat response times

Takes a tomcat log and processes the response time column and outputs the number of requests in 3 different response-time buckets.

The response time buckets can be configured but by default they are under 300ms(green), over 300ms and under 1000ms(yellow), and over 1000ms(red)

The data is presented for the whole file and broken down by hour by defaults 

There are several options available:

- output the break downs increments to as small as 1 minute increments.

- option is a verbose option to show percentage of each response time bucket within the hour.

- option to ouput the responses that fall under the yellow or red response time bucket into a separate file
