# Description:
#   OpenDNS Umbrella Passive DNS & Reputation
#
# Dependencies:
#   None
#
# Configuration:
#   OPENDNS_KEY - Sign up at https://investigate.opendns.com
#
# Commands:
#   hubot opendns <url> - Gets OpenDNS Domain Reputation
#
# Author:
#   Scott J Roberts - @sroberts

VIRUSTOTAL_API_KEY = process.env.VIRUSTOTAL_API_KEY
vt_url = "https://www.virustotal.com"

vt_file_report_url = vt_url + "/vtapi/v2/file/report"
vt_url_report_url = vt_url + "/vtapi/v2/url/report"
vt_ip_report_url = vt_url + "/vtapi/v2/ip-address/report"

module.exports = (robot) ->
  robot.respond /virustotal hash (.*)/i, (msg) ->

    if VIRUSTOTAL_API_KEY?
      hash = msg.match[1].toLowerCase()
      data = "apikey=#{encodeURIComponent VIRUSTOTAL_API_KEY}&resource=#{encodeURIComponent hash}"

      robot.http(vt_file_report_url)
        .post(data) (err, res, body) ->
          if res.statusCode is 200
            vt_json = JSON.parse(body)

            if vt_json.response_code == 1
              summary = """VirusTotal Result: #{vt_json.resource}
              - Scanned at: #{vt_json.scan_date}
              - Results:    #{vt_json.positives}/#{vt_json.total}
              - Link:       #{vt_json.permalink}
              """

              msg.send summary

            else
              msg.send "VirusTotal URL Analysis: #{vt_json.verbose_msg}"
          else
            msg.send "Error: Couldn't access #{vt_url}."
    else
      msg.send "VirusTotal API key not configured. Get one at https://www.virustotal.com/en/user/ in the API tab"