'use strict';

const logger = require('fancy-log');
const fractal = require('../../fractal');

module.exports = {
    task: params => {
        return function () {
            // fractal.on('source:updated', function (source, eventData) {
            //     logger.info(eventData);//`Update in ${source.path} directory`);
            // });
            fractal.web.set('server.sync', true);
            fractal.web.set('server.syncOptions', {
                open: false, //'local',
                ignore: ['public/typo3conf/ext/*/Components/**/*'],
                reloadDebounce: 1000,
                logFileChanges: true,
            });
            const syncServer = fractal.web.server();
            syncServer.on('error', err => logger.error(err.message));
            return syncServer.start()
                .then(() => {
                    logger.info(`Fractal server is now running at ${syncServer.url}`);
                });
        };
    },
    dtp: 2
};
