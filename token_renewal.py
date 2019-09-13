import common
import kms_utils
import threading
import time

logger = None


class TokenRenewal(threading.Thread):

    def __init__(self):
        threading.Thread.__init__(self, daemon=True)

        global logger
        logger = common.marathon_lb_logger.getChild('token_renewal.py')
        self.period = 45
        logger.info('Starting token renewal thread')

    def run(self):
        while True:
            logger.info('Checking if token needs renewal')

            try: 
                kms_utils.check_token_needs_renewal(False)

            except Exception as e:
                logger.error('Something went wrong when checking the token')
                logger.error(e)

            time.sleep(self.period)


