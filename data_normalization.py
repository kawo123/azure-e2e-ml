#!/usr/bin/env python3
"""
Normalize UCI computer hardware dataset (http://archive.ics.uci.edu/ml/datasets/Computer+Hardware)

1. vendor name: 30
(adviser, amdahl,apollo, basf, bti, burroughs, c.r.d, cambex, cdc, dec,
dg, formation, four-phase, gould, honeywell, hp, ibm, ipl, magnuson,
microdata, nas, ncr, nixdorf, perkin-elmer, prime, siemens, sperry,
sratus, wang)
2. Model Name: many unique symbols
3. MYCT: machine cycle time in nanoseconds (integer)
4. MMIN: minimum main memory in kilobytes (integer)
5. MMAX: maximum main memory in kilobytes (integer)
6. CACH: cache memory in kilobytes (integer)
7. CHMIN: minimum channels in units (integer)
8. CHMAX: maximum channels in units (integer)
9. PRP: published relative performance (integer)
10. ERP: estimated relative performance from the original article (integer)
"""

import argparse
import pandas as pd
from logzero import logger


def main(args):
    """ Main entry point of the app """
    data_path = args.data_path
    output_path = args.output_path

    machine_data_df = pd.read_csv(data_path, header='infer')

    # Vendor table (VendorId, VendorName)
    vendors = machine_data_df['VendorName'].unique()
    vendors_id = [x + 1 for x in list(range(vendors.shape[0]))]
    vendors_df = pd.DataFrame(data={'VendorId': vendors_id, 'VendorName': vendors})
    df = pd.merge(machine_data_df, vendors_df, on='VendorName')

    normalized_machine_data_df = df.drop(columns=['VendorName'])

    # Write CSV
    normalized_machine_data_df.to_csv(output_path + '/normalizedMachineData.csv', index=False)
    logger.info(f"{output_path}/normalizedMachineData.csv created and populated.")
    vendors_df.to_csv(output_path + '/vendors.csv', index=False)
    logger.info(f"{output_path}/vendors.csv created and populated.")


if __name__ == "__main__":
    """ This is executed when run from the command line """
    parser = argparse.ArgumentParser()

    # Optional argument flag which defaults to False
    parser.add_argument("-f", "--flag", action="store_true", default=False)

    # Optional argument which requires a parameter (eg. -d test)
    parser.add_argument("-d", "--data", action="store", dest="data_path", default='./data/machineData.csv')

    # Optional argument which requires a parameter (eg. -o test)
    parser.add_argument("-o", "--output", action="store", dest="output_path", default='./data')

    args = parser.parse_args()
    main(args)