from sdcclient import IbmAuthHelper, SdMonitorClient
import csv
import datetime

URL = 'https://us-south.monitoring.cloud.ibm.com'
APIKEY = "API KEY OF IBM CLOUD"

GUID = "GUID of the monitoring instance"

ibm_headers = IbmAuthHelper.get_headers(URL, APIKEY, GUID)
sdclient = SdMonitorClient(sdc_url=URL, custom_headers=ibm_headers)

# Specify the metrics you want to fetch
metrics = [
    {"id": "jvm.class.loaded"},
    {"id": "jvm.class.unloaded"},
    {"id": "jvm.gc.global.count"},
    {"id": "jvm.gc.global.time"},
    {"id": "jvm.gc.scavenge.time"},
    {"id": "jvm.heap.committed"},
    {"id": "jvm.heap.used"},
    {"id": "jvm.heap.used.percent"},
    {"id": "jvm.nonHeap.committed"},
    {"id": "jvm.nonHeap.used"},
    {"id": "jvm.nonHeap.used.percent"},
    {"id": "jvm.thread.count"},
    {"id": "sysdig_container_cpu_used_percent"},
    {"id": "sysdig_container_memory_used_percent"},
    {"id": "sysdig_container_net_connection_total_count"},
    {"id": "sysdig_container_net_total_bytes"} 
]

filter = "kube.namespace.name = '%s'" %"acmeair"
ok, res = sdclient.get_data(metrics=metrics,  # List of metrics to query
                            start_ts=-1800,  # Start of query span is 600 seconds ago
                            end_ts=0,  # End the query span now
                            sampling_s=10,  # 1 data point per minute
                            datasource_type='container',
                           filter=filter)  # The source for our metrics is the container
if ok:
    with open('metrics.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        header_row = [metric['id'] for metric in metrics]
        header_row.append("timestamp")  # Add the "timestamp" column header
        writer.writerow(header_row)

        start_time = datetime.datetime.now() - datetime.timedelta(minutes=30) 
        interval = datetime.timedelta(seconds=10) 
        end_time = start_time + datetime.timedelta(minutes=30) 
        while_flag= False
        while start_time <= end_time:
            for temp_res in res['data']:
                row = temp_res['d']
                timestamp = start_time.strftime("%Y-%m-%d %H:%M:%S") 
                row.append(timestamp)
                start_time += interval
                if(start_time>end_time):
                    while_flag=True
                    break
                writer.writerow(row)
            if(while_flag):
                break

    print("Metrics saved to metrics.csv file.")