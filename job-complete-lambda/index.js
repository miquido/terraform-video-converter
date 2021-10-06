/**
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *  SPDX-License-Identifier: Apache-2.0
 */
const utils = require('./lib/utils.js');

exports.handler = async (event) => {
    console.log(`REQUEST:: ${JSON.stringify(event, null, 2)}`);

    const {
        MEDIACONVERT_ENDPOINT,
        CLOUDFRONT_DOMAIN,
        NOTIFICATION_WEBHOOK
    } = process.env;

    try {
        const status = event.detail.status;

        switch (status) {
            case 'INPUT_INFORMATION':
                break;
            case 'COMPLETE':
                try {
                    /**
                     * get the mediaconvert job details and parse the event outputs
                     */
                    const jobDetails = await utils.processJobDetails(MEDIACONVERT_ENDPOINT,CLOUDFRONT_DOMAIN,event);
                    await utils.sendNotification(NOTIFICATION_WEBHOOK, jobDetails);
                    await utils.deleteSourceFile(jobDetails.Job.Settings.Inputs[0].FileInput);
                } catch (err) {
                    throw err;
                }
                break;
            case 'CANCELED':
            case 'ERROR':
                try {
                    await utils.sendNotification(NOTIFICATION_WEBHOOK, event);
                } catch (err) {
                    throw err;
                }
                break;
            default:
                throw new Error('Unknown job status');
        }
    } catch (err) {
        await utils.sendNotification(NOTIFICATION_WEBHOOK, err);
        throw err;
    }
    return;
};