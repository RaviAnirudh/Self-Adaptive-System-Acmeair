from sdcclient import IbmAuthHelper, SdMonitorClient
import csv
from datetime import datetime, timedelta
import subprocess
import time

time_limit = 30 * 60  
flag_limit = 5 * 60


URL = 'URL of the cluster'
APIKEY = "API KEY OF IBM CLOUD"

GUID = "GUID of the monitoring instance"

start_time = time.time()
aIf = False
aDf = False

while True:
    current_time = time.time()
    elapsed_time = current_time - start_time
    script_path = "path of the script"
    if elapsed_time >= time_limit:
        print("Time limit reached. Stopping execution.")
        break
    if current_time - start_time >=60 :
        start_time = current_time
        if elapsed_time == flag_limit:
            aIf = False
            aDf = False
        ibm_headers = IbmAuthHelper.get_headers(URL, APIKEY, GUID)
        sdclient = SdMonitorClient(sdc_url=URL, custom_headers=ibm_headers)
        filter = "kube.namespace.name = '%s'" %"acmeair"
        metrics = [ {"id": "sysdig_container_cpu_cores_used_percent",
             "aggregations": {
             "time": "avg",  
             "group":"max"
     }}]
        ok, res = sdclient.get_data(metrics=metrics,  # List of metrics to query
                            start_ts=-60,  # Start of query span is 600 seconds ago
                            end_ts=0,  # End the query span now
                            sampling_s=10,  # 1 data point per minute
                            datasource_type='container',
                            filter=filter)  # The source for our metrics is the container

        val=[]
        if ok:
            for temp_res in res['data']:
                val.append(temp_res['d'][0])
            avg= sum(val)/(len(val)-1)
            if avg > 60 and not aIf:
                aIf = True
                aDf = False
                print("Running increase of pods")
                subprocess.run(["bash", bash_script_path, "0"], check=True)
            if avg < 60 and not aDf:
                aDf = True
                aIf = False
                print("Running decrease of pods")
                subprocess.run(["bash", bash_script_path, "1"], check=True)
                
print("Code execution completed.")
