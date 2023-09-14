import csv
from datetime import datetime, timedelta

input_file_Jmeter = 'C:\\Users\\ranir\\Desktop\\jmeter-10.csv'
input_file_metrics= 'C:\\Users\\ranir\\Desktop\\acmeair\\metrics.csv'
output_file = 'output_converted.csv'

def convert_timestamp(timestamp,flag):
    formatted_time = ""
    if (flag):
        timestamp_s = float(timestamp)/1000
        local_datetime = datetime.fromtimestamp(timestamp_s)
        formatted_time = local_datetime.strftime("%H:%M:%S")
    else:
        formatted_time = timestamp[11:]
    return formatted_time

def addTime(st):
    datetime_obj = datetime.strptime(st, '%Y-%m-%d %H:%M:%S')
    updated_datetime_obj = datetime_obj + timedelta(seconds=10)
    updated_string_time = updated_datetime_obj.strftime('%Y-%m-%d %H:%M:%S')
    return (updated_string_time)
def compTimes(time1,time2):
    t1 = time1[3:].replace(":", "")
    t2 = time2[3:].replace(":", "")
    if(t1>t2):
        return True
    else:
        return False

with open(input_file_Jmeter, 'r') as csv_input_jm, open(input_file_metrics, 'r') as csv_input_met, open('op.csv', 'w', newline='') as csv_op:
    writer = csv.writer(csv_op)    
    reader = csv.reader(csv_input_jm)
    jmr = list(reader)
    read = csv.reader(csv_input_met)
    met_rows = list(read)
    head = ["No Of Requests","Throughput","Latency","Bytes","Failed Request","Successfull Request",
           "Login","Book Flight", "List Booking","Query Flight","Update Customer Profile",
           "Cancel Booking "]
    new_header_row = met_rows[0] + head
    writer.writerow(new_header_row)
    i=1
    for mr in met_rows[1:]:
        row = mr
        temp = []
        throughput = 0
        noOfReq = 0
        successfullReq = 0
        failedReq = 0
        loginReq = 0
        bookflightReq = 0
        listBookingReq = 0
        queryflightreq = 0
        viewProfInfoReq = 0
        updCustReq = 0
        canBookReq = 0
        latency = 0
        byte = 0
        init= convert_timestamp(mr[-1],False)
        end = convert_timestamp(addTime(mr[-1]),False)
        while (i < len(jmr)):
            noOfReq+=1
            ts = convert_timestamp(jmr[i][0],True)
            if (compTimes(end,ts)):
                if(jmr[i][7].lower() == 'false'):
                    failedReq += 1 
                else:
                    successfullReq += 1
                if (jmr[i][2].replace(" ", "").lower() == "login"):
                    loginReq+=1
                elif (jmr[i][2].replace(" ", "").lower() == "bookflight"):
                    bookflightReq+=1
                elif (jmr[i][2].replace(" ", "").lower() == "listbookings"):
                    listBookingReq+=1
                elif (jmr[i][2].replace(" ", "").lower() == "queryflight"):
                    queryflightreq+=1
                elif (jmr[i][2].replace(" ", "").lower() == "cancelbooking"):
                    canBookReq+=1
                elif (jmr[i][2].replace(" ", "").lower() == "updatecustomer"):
                    updCustReq+=1
                else:
                    viewProfInfoReq+=1
                byte += float(jmr[i][8])
                latency += float(jmr[i][11])
                i+=1
            else:
                break
        if(noOfReq<=0):
            throughput=0
            latency=0
            byte=0
        else:
            throughput = noOfReq / 10
            latency = latency / noOfReq
            byte = byte / noOfReq
        temp = [noOfReq,throughput,latency,byte,failedReq,successfullReq,loginReq,bookflightReq,listBookingReq
                ,queryflightreq,updCustReq,canBookReq]
        row += temp
        writer.writerow(row)
print("Results saved to results.csv")        