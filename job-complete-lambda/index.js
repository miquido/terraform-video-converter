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
                    const jobDetails = await utils.getJobDetails(MEDIACONVERT_ENDPOINT,CLOUDFRONT_DOMAIN,event);
                    const urls = utils.getCloudFrontUrls(CLOUDFRONT_DOMAIN, event)
                    const notification = {
                      event: event,
                      jobDetails : jobDetails,
                      cfUrls : urls,
                    }
                    await utils.sendNotification(NOTIFICATION_WEBHOOK, notification);
                    await utils.deleteSourceFile(jobDetails.Job.Settings.Inputs[0].FileInput);
                } catch (err) {
                    throw err;
                }
                break;
            case 'CANCELED':
            case 'ERROR':
                try {
                    const notification = {
                      event: event,
                    }
                    await utils.sendNotification(NOTIFICATION_WEBHOOK, notification);
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
