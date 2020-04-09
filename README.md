# SIPp by Examples

## Introduction

This document provides some step-by-step examples using SIPp in order to emulate different call scenarios.

## Requirements:

**IMPORTANT: In order to execute all the examples, you will need:**

- A computer with SIPp installed
- A SIP Proxy ([SPLiT](https://github.com/pbertera/SPLiT) or other)
- One or more Snom phone.
- A file editor; one with XML syntax highlighting and validation support is preferred
- A computer equipped with:
    - Ethernet card (10/100 or Gigabit)
    - Supported operating systems: GNU/Linux, Mac OSX > 10.4
    - You must have administrator privileges
    - [Wireshark](https://www.wireshark.org) installed
    - SIPp installed (scenario are tested with SIPp v3.5.1 with `PCAP` and `RTPSTREAM` features)

### How to work with the example code

This document refers to some example scenario that can be found in this repository.

You can clone the repository using the `git` command: `git clone https://github.com/pchero/sipp-examples`. Every directory contains a discussed example.

# SIPp main features:

**SIPp** is a tool originally developed to benchmark SIP proxy and UAs. SIPp provides a list of complex features like

* Builtin scenarios
* Custom XML-defined scenarios
* Statistics generation
* Control channel
* RTP echo
* PCAP playback

The tool was originally developed by Hewlett-Packard, now is maintained by an OSS community on Github

Here some important online resources:

* Main documentation [reference](http://sipp.sourceforge.net/doc3.3/reference.html/)
* Project homepage on [github](https://github.com/SIPp/sipp)
* [Mailing list](https://lists.sourceforge.net/lists/listinfo/sipp-users)

# Basic concepts

SIPp is a tool capable the send and receive SIP messages, can operate both as a UAC and UAS. The message exchange must be defined in a scenario file.

One of the biggest SIPp limitations is that the tool can handle only one SIP dialog (one Call-ID) in a scenario, however there is some workaround that can be adopted in some situations.

## SIPp command line options:

Following a list of the most common command line options. You can obtain the full list executing the command `sipp -h`.

##### Scenario options

* `-sn <scenario>`: use a builtin scenario (*uas*, *uac*, *regexp*, ...)
* `-sd <scenario>`: dump the XML implementing the builtin scenario
* `-sf <scenario-file>`: load a custom scenario file
* `-set <var> <val>`: set the variable *var* with *val* value, the variable can then used into the scenario file as `[$var]`

##### SIP IP address and port

* `-i <local_ip>`: set the local IP address for the *Contact*, *Via* and *From* headers, can be referenced with `[local_ip]` keyword into a scenario file. Applies to the SIP protocol only.
* `-p <local_port>`: set the local port for the SIP protocol. Can be referenced using the `[local_port]`keyword.

##### Media and RTP options

* `-mi <media_ip>`: set the local media IP address, this value can also be referred using the `[media_ip]` keyword into the scenario file
* `-mp <media_port>`: set the local media port, this value can also be referred using the `[media_port]` keyword into the scenario file
* `-rtp_echo`: Enable RTP echo. RTP/UDP packets received on port defined by -mp are echoed to their sender.

##### Call rate options

* `-l <max_calls>`: set the maximum number of simultaneous calls
* `-m <calls>`: Stop the test and exit when *calls* calls are processed

##### Tracing and logging options

* `-trace_msg`: dump sent and received SIP messages in `<scenario_file_name>_<pid>_messages.log`
* `-message_file`: Set the name of the message log file
* `-trace_err`: trace all unexpected messages in `<scenario_file_name>_<pid>_errors.log`
* `-error_file`: set the name of the error log file
* `-trace_logs`: allow tracing of <log> actions in `<scenario_file_name>_<pid>_logs.log`
* `-log_file`: set the name of the log actions log file

## SIPp scenario file syntax

* root XML tag is named **scenario** and must have the **name** attribute:

    ```xml
    <?xml version="1.0" encoding="utf-8" ?>
    <scenario name="Basic UAC custom scenario">
      <!-- here your scenario -->
    </scenario>
    ```

### Scenario commands

Here is a lost of the most important scenario commands:

* `<send>`: send a SIP message or a response. Important attributes are:
    * `retrans`: set the T1 timer for this message in milliseconds
    * `lost`: emulate packet lost, value in percentage

* `<recv>`: wait for a SIP message or response. Important attributes are:
    * `response`: indicates what SIP message code is expected
    * `request`: indicates what SIP message request is expected
    * `optional`: Indicates if the message to receive is optional. If optional is set to "global", SIPp will look every previous steps of the scenario
    * `lost`: emulate packet lost, value in percentage
    * `timeout`: specify a timeout while waiting for a message. If the message is not received, the call is aborted
    * `ontimeout`: specify a label to jump to if the timeout popped
regexp_match: boolean. Indicates if 'request' ('response' is not available) is given as a regular expression.

    The `recv` command can also include the action tag defining the action to execute upon the message reception

* `pause`: pause the scenario execution. Important attributes are:
    * `milliseconds`: time to pause in milliseconds
    * `variable`: scenario variable defining the pause time

* `nop`: the `nop` action doesn’t do nothing at SIP signalling level, is just a tag containing the `action` subtag

* `sendCmd`: content to be sent to the twin 3PCC (3rd Party Call Control) SIPp instance. The Call-ID must be included

* `recvCmd`: specify an action when receiving the command

* `label`: a label is used when you want to branch to specific parts in your scenarios

#### Common command attributes

Here is a list of attributes common to all the scenario commands:

* `crlf`: Displays an empty line after the arrow for the message in main SIPp screen
* `next`: You can put a "next" in any command element to go to another part of the script when you are done with sending the message. For optional receives, the next is only taken if that message was received
* `test`: You can put a "test" next to a "next" attribute to indicate that you only want to branch to the label specified with "next" if the variable specified in "test" is set
* `display`: Display a text into the SIPp screen


### Scenario keywords

Inside the `send` command, you have to enclose your SIP message between the `<![CDATA` and the `]]>` tags.

Everything between those tags is going to be sent toward the remote system.
Into the SIP message you can include some keywords (Eg. `[service]`, `[remote_ip]`, etc..).

Those keywords will get replaced at runtime by SIPp.

* `[service]`: service field, as passed in the -s <service_name> command line option (default: service)
* `[remote_ip]` and `[remote_port]`: remote IP address and port
* `[transport]`: the transport mode (depending on the -t CLI parameter) (default: UDP)
* `[local_ip]`, `[local_ip_type]`, `[local_port]`: depending on the `-l` and `-p` CLI params. Type can be **4** or **6**
* `[len]`: computed length of the SIP body. To be used in *Content-Length* header
* `[cseq]`: generates automatically the *CSeq* number
* `[call_id]`: a call_id identifies a call and is generated by SIPp for each new call. In client mode, it is mandatory to use the value generated by SIPp in the *Call-ID* header
* `[media_ip]`, `[media_ip_type]`, `[media_port]`: depending on the value of *-mi* and *-mp* params.
* `[last_*]`: is replaced automatically by the specified header if it was present in the last message received (Eg. `[last_From]`)

### Scenario actions

In a `recv`, `recvCmd` or `nop` command you can execute one or more actions:

* `ereg`: execute a regular expression matching
* `log`: write a log message
* `exec`: execute a command on the operating system shell, or an internal SIPp command or play a pcap file
* `jump`: jump to an arbitrary scenario index

# Creating an UAC scenario

1. An UAC scenario starts with a `send` command:

    ```xml
    <?xml version="1.0" encoding="UTF-8" ?>
    <scenario name="Basic UAC scenario">
     <send>
      <![CDATA[  
      INVITE sip:[service]@[remote_ip]:[remote_port] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port]
      From: sipp <sip:sipp@[local_ip]:[local_port]>;tag=[call_number]
      To: sut <sip:[service]@[remote_ip]:[remote_port]>
      Call-ID: [call_id]
      Cseq: 1 INVITE
      Contact: sip:sipp@[local_ip]:[local_port]
      Content-Type: application/sdp
      Content-Length: [len]
      
      v=0
      o=user1 53655765 2353687637 IN IP[local_ip_type] [local_ip]
      s=-
      t=0 0
      c=IN IP[media_ip_type] [media_ip]
      m=audio [media_port] RTP/AVP 0
      a=rtpmap:0 PCMU/8000
      ]]>
     </send>
    ```
    
1. The scenario waits for an answer: `100 Trying` and `180 Ringing` are optional. the `200 OK` is mandatory.

    ```xml
     <recv response="100" optional="true">
     </recv>
     
     <recv response="180" optional="true">
     </recv>
     
     <recv response="200">
     </recv>
    ```
    
1. Once the `200 OK` is received the scenario sends the `ACK` and waits for 5 seconds:
    
    ```xml
     <send>
      <![CDATA[
      ACK sip:[service]@[remote_ip]:[remote_port] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port]
      From: sipp <sip:sipp@[local_ip]:[local_port]>;tag=[call_number]
      To: sut <sip:[service]@[remote_ip]:[remote_port]>[peer_tag_param]
      Call-ID: [call_id]
      Cseq: 1 ACK
      Contact: sip:sipp@[local_ip]:[local_port]
      Content-Length: 0
      ]]>
     </send>
     <pause milliseconds="5000"/>
    ```

1. The scenario terminates sending a `BYE` and waiting for the `200 OK`:
    
    ```xml
     <send retrans="500">
      <![CDATA[
      BYE sip:[service]@[remote_ip]:[remote_port] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port]
      From: sipp  <sip:sipp@[local_ip]:[local_port]>;tag=[call_number]
      To: sut  <sip:[service]@[remote_ip]:[remote_port]>[peer_tag_param]
      Call-ID: [call_id]
      Cseq: 2 BYE
      Contact: sip:sipp@[local_ip]:[local_port]
      Content-Length: 0
      ]]>
     </send>
     <recv response="200">
     </recv>
    </scenario>
    ```

# Creating an UAS scenario

1. An UAS scenario starts with a `recv` command, the scenario replies with `180 Ringing`. The scenario extract the `From` header value and the `Contact` SIP URI from the request:
    
    ```xml
    <?xml version="1.0" encoding="UTF-8" ?>
    <scenario name="Basic UAS scenario">
     <recv request="INVITE">
      
      <action>
       <!-- since we need to send a request to the remote part -->
       <!-- we need to extract the Contact and the From header content -->
       <ereg regexp=".*" search_in="hdr" header="From" assign_to="remote_from"/>
       <!-- assign the content of the Contaact SIP URI to the remote_contact var -->
       <!-- first var of assign_to contains the whole match -->
       <ereg regexp="sip:(.*)>.*" search_in="hdr" header="Contact" assign_to="trash,remote_contact"/>
      </action>
     </recv>
     <!-- since SIPp complains about not used variable reference the trach var -->
     
     <Reference variables="trash"/>
    ```

1. Now the scenario should answer the call with 200 OK and wait for the ACK message:

    ```xml
     <send retrans="500">
      <![CDATA[
      SIP/2.0 200 OK
      [last_Via:]
      [last_From:]
      [last_To:];tag=[pid]SIPpTag01[call_number]
      [last_Call-ID:]
      [last_CSeq:]
      Contact: <sip:[local_ip]:[local_port];transport=[transport]>
      Content-Type: application/sdp
      Content-Length: [len]
      
      v=0
      o=user1 53655765 2353687637 IN IP[local_ip_type] [local_ip]
      s=-
      c=IN IP[media_ip_type] [media_ip]
      t=0 0
      m=audio [media_port] RTP/AVP 0
      a=rtpmap:0 PCMU/8000
      ]]>
     </send>
     <recv request="ACK" optional="true" crlf="true">
     </recv>
    ```


1. To end the call the scenario waits for the `BYE` and accept it with `200 OK`. In case the `BYE` is not received in 3000 ms the scenario jumps to the `send_bye` label:

    ```xml
     <recv request="BYE" timeout="3000" ontimeout="send_bye">
     </recv>
     <send>
      <![CDATA[
      SIP/2.0 200 OK
      [last_Via:]
      [last_From:]
      [last_To:]
      [last_Call-ID:]
      [last_CSeq:]
      Contact: <sip:[local_ip]:[local_port];transport=[transport]>
      Content-Length: 0
      ]]>
     </send>
     
     <nop>
      <action>
       <exec int_cmd="stop_now"/>
      </action>
     </nop>
    ```

1. Define the `send_bye` label:

    ```xml
     <label id="send_bye"/>
    ```

1. Send the `BYE` and wait for the `200 OK`
    
    ```xml
     <send retrans="500">
      <![CDATA[
      BYE [$remote_contact] SIP/2.0
      Via: SIP/2.0/[transport] [local_ip]:[local_port]
      From: sipp  <sip:sipp@[local_ip]:[local_port]>;tag=[pid]SIPpTag01[call_number]
      To: [$remote_from]
      Call-ID: [call_id]
      Cseq: 2 BYE
      Contact: sip:sipp@[local_ip]:[local_port]
      Content-Length: 0
      ]]>
     </send>
     
     <recv response="200">
     </recv>
    </scenario> 
    ```

**NOTE: Both UAC and UAS scenario can be found into the Basic folder: [Basic/uac.xml](Basic/uac.xml) and [Basic/uas.xml](Basic/uas.xml)**

# Specific settings for SIPp and Snom phones

If you want to run and UAC against a Snom phone (calling the phone from SIPp), you should pay attention the following points:

* disable the [filter_registrar](http://wiki.snom.com/wiki/index.php/Settings/filter_registrar) unless you are not running the SIPp from the PBX
* configure the [network_id_port](http://wiki.snom.com/wiki/index.php/Settings/network_id_port) unless you don't want to figure out from the phone registration (look at the `Contact` header sent by the phone during the registration)
* configure the [user_sipusername_as_line](http://wiki.snom.com/wiki/index.php/Settings/user_sipusername_as_line) unless you don't want to figure out from the phone registration (look at the `Contact` header sent by the phone during the registration)
* you should use the `-s` command line option to define the `[service]` keyword containing the SIP identity username

If you want to call an UAS scenario from a Snom phone the simplest way is to configure a speed dial function key calling the SIPp scenario, Eg.: `fkey3=speed sip:sipp@172.16.18.55:5060`, where `172.16.18.55` is the SIPp address and `5060`is the SIPp port.

# Some sample scenario

## SIP Call with re-INVITE

This scenario is quite similar to the basic described before: UAC sends an INVITE containing the SDP offer, once the dialog is established the UAC sends an in-dialog INVITE.

### The UAS

**Scenario file:** [reINVITE-PAI/uas.xml](reINVITE-PAI/uas.xml)

`./sipp -sf reINVITE-PAI/uas.xml -i <local_ip> -p <local_port> -m 1`

Where:

* **<local_ip>** is the local IP address
* **<local_port** is the local SIP port

### The UAC

**Scenario file:** [reINVITE-PAI/uac-active.xml](reINVITE-PAI/uac-active.xml)

`sipp -sf reINVITE-PAI/uac-active.xml -m 1 -s <service> -i <local_ip> <remote_ip>:<remote_port>`

Where:

* **<local_ip>** is the local IP address
* **<remote_ip>** is the remote IP address
* **<remote_port>** is the remote port
* **<service>** is the called service, if you are calling a phone should be username.

## Active Media call scenario

The folder [Active-Media](Active-Media) contains UAS and UAC scenarios for Active media negotiation (SDP offer sent into the INVITE request).

The UAC is responsible for the dialog creation and closure.

### The UAS

**Scenario file:** [Active-Media/uas-active.xml](Active-Media/uas-active.xml)

Since the UAS scenario is playing a PCAP file, SIPp should run with a priviledged user.

`sudo sipp -sf Active-Media/uas-active.xml -i <local_ip> -p <local_port> -m 1`

Where:

* **<local_ip>** is the local IP address
* **<local_port** is the local SIP port

### The UAC

**Scenario file:** [Active-Media/uac-active.xml](Active-Media/uac-active.xml)

`sudo sipp -sf Active-Media/uac-active.xml -m 1 -s <service> -i <local_ip> <remote_ip>:<remote_port>`

Where:

* **<local_ip>** is the local IP address
* **<remote_ip>** is the remote IP address
* **<remote_port>** is the remote port
* **<service>** is the called service, if you are calling a phone should be username.

### RTP Echo

If you want to use the RTP echo feature instead of playing a PCAP file you can commend out the section:

```xml
  <nop>
    <action>
        <exec play_pcap_audio="../pcap/g711a.pcap"/>
    </action>
  </nop>
```

and then add the `-rtp_echo` option to the SIPp command line

## Passive Media call scenarios

The folder [Passive-Media](Passive-Media) contains UAS and UAC scenarios for Passive media negotiation (SDP offer sent into the `200 OK`).

The UAC is responsible for the dialog creation and closure.

### The UAS

**Scenario file:** [Passive-Media/uas-passive.xml](Passive-Media/uas-passive.xml)

Since the UAS scenario is playing a PCAP file should run with a proviledged user.

`sudo sipp -sf Passive-Media/uas-passive.xml -i <local_ip> -p <local_port> -m 1`

Where:

* **<local_ip>** is the local IP address
* **<local_port** is the local SIP port

### The UAC

**Scenario file:** [Passive-Media/uac-passive.xml](Passive-Media/uac-passive.xml)

`sudo sipp -sf Passive-Media/uac-passive.xml -m 1 -s <service> -i <local_ip> <remote_ip>:<remote_port>`

Where:

* **<local_ip>** is the local IP address
* **<remote_ip>** is the remote IP address
* **<remote_port>** is the remote port
* **<service>** is the called service

## Hold call scenario (hold from UAC)

The folder [Hold-UAC](Hold-UAC) contains UAS and UAC scenarios for call hold using the [RFC 3264](https://tools.ietf.org/html/rfc3264) specification (`a=sendonly/recvonly`).

In this scenario the UAC sends the first INVITE, and the hold and retrieve re-INVITEs.

### The UAS

**Scenario file:** [Hold-UAC/uas-hold.xml](Hold-UAC/uas-hold.xml)

Since the UAS scenario is playing a PCAP file should run with a proviledged user.

`sudo sipp -sf Hold-UAC/uas-hold.xml -i <local_ip> -p <local_port> -m 1`

Where:

* **<local_ip>** is the local IP address
* **<local_port** is the local SIP port

The scenario expects 2 re-INVITE from the UAC (first putting the call on hold and second retrieving the call).

### The UAC

**Scenario file:** [Hold-UAC/uac-hold.xml](Hold-UAC/uac-hold.xml)

`sudo sipp -sf Hold-UAC/uac-hold.xml -m 1 -s <service> -i <local_ip> <remote_ip>:<remote_port>`

Where:

* **<local_ip>** is the local IP address
* **<remote_ip>** is the remote IP address
* **<remote_port>** is the remote port
* **<service>** is the called service

## Hold call scenario (hold from UAS)

The scenario in the [Hold-UAS](Hold-UAS) folder is a little bit different from the previous one: in this case the hold re-INVITE is send by the UAS. For this reason the UAS need to save the original `From` header and the `Contact` URI from the UAC request.

### The UAS

**Scenario file:** [Hold-UAS/uas-hold.xml](Hold-UAS/uas-hold.xml)

You can run the UAS scenario using the command:

`sipp -sf Hold-UAS/uas-hold.xml -i <local_ip> -p <local_port> -m 1`

Where:

* **<local_ip>** is the local IP address
* **<local_port** is the local SIP port

The scenario expects an INVITE from the UAC, after receiving the INVITE the UAS accepts the call and sends a re-INVITE with `a=sendonly`.

### The UAC

**Scenario file:** [Hold-UAS/uac-hold.xml](Hold-UAS/uac-hold.xml)

You can run the UAC scenario using the command:

`sipp -sf Hold-UAS/uac-hold.xml -i <local_ip> -s <service> -m 1 <remote_ip>:<remote_port>`

Where:

* **<local_ip>** is the local IP address
* **<remote_ip>** is the remote IP address
* **<remote_port>** is the remote port
* **<service>** is the called service


## UAS MWI notification

**Scenario file:** [MWI-unsolicited/uas-mwi.xml](MWI-unsolicited/uas-mwi.xml)

This scenario accepts an UAC registration, the scenario accepts the REGISTER and then sends some unsolicited NOTIFY containing the MWI notification.

You can run the UAS scenario using the command:

`sipp -sf MWI-unsolicited/uas-mwi.xml -i 172.16.18.69 -m 1 -p 5060`

Please note that this scenario is using the same Call-ID for the REGISTER reply and the NOTIFY.

To use this scenario with a Snom phone you can configure an identity with SIPp IP address as registrar.

## UAS BLF implementing the signalling defined by RFC4235

**Scenario file:** [BLF/uas-blf-recipient.xml](BLF/uas-blf-recipient.xml)

This UAS scenario implements the protocol and syntax described by [RFC 4235](https://tools.ietf.org/html/rfc4235) defining the BLF functionality

The scenario simulates a monitored SIP entity receiving a call

### Executing the scenario

You can execute the scenario running the following command:

* *local_display* defines the local display name of the incoming dialog
* *local_identity* defines the local identity of incoming dialog
* *local_uri* defines the caller URI
* *remote_display* defines the remote display name of the incoming dialog
* *remote_identity* defines the remote identity of the incoming dialog
* *target_uri* defines the remote contact of the incoming dialog

**Example:**

```
    sipp -sf BLF/uas-blf-recipient.xml -i 172.16.18.69 -m 1 \
    -key local_display Bob \
    -key local_identity bob@houseofbob:5060 \
    -key local_uri sip:bob@wonderlan.com \
    -key remote_display Carl \
    -key remote_identity carl@carl@houseofcarl:5060 \
    -key target_uri bob@wonderland.com \
```

### Call diagram

* **A** is the monitoring UAC
* **B** is registered with *Contact: bob@houseofbob.com:5060*, AOR is *bob@wonderland.com* and displayname is "Bob"
* **C** is registered with *Contact: carl@houseofcarl.om:5060*, AOR is *carl@wonderland.com* and displayname is "Carl"
* **C** calls **B* INVITING the URI bob@wonderland.com

```
A               B                C
|               |                |
|   SUBSCRIBE   |                |
|-------------->|                |
|               |                |
|  202 Accepted |                |
|<--------------|                |
|               |   INVITE       |
|               |<---------------|
|               |                |-+
|               |  180 Ringing   | |
|               |--------------->| |
|  NOTIFY       |                | |
|<--------------|                | | EARLY
|               |                | |
|  200 OK       |                | |
|-------------->|                | |
|               |   200 OK       | |
|               |--------------->|-+
|               |     ACK        | 
|               |<---------------|-+ 
|  NOTIFY       |                | |
|<--------------|                | |
|               |                | |
|  200 OK       |                | | CONNECTED
|-------------->|                | |
|               |     BYE        | |
|               |<---------------|-+
|               |     200 OK     |
|               |--------------->|-+
|  NOTIFY       |                | |
|<--------------|                | | TERMINATED
|               |                | |
|  200 OK       |                | |
|-------------->|                |-+
```

**Note usage with a Snom Phone as UAC:** after executing the scenario you should configure a function key as a BLF monitoring the SIPp instance, Eg.: `fkey3=blf sipp@172.16.18.69`

## Call Pickup with 3PCC (Replaces header)

**Scenario files:** [Call-pickup-3pcc/uac-3pcc-C-A.xml](Call-pickup-3pcc/uac-3pcc-C-A.xml) and [Call-pickup-3pcc/uac-3pcc-C-B.xml](Call-pickup-3pcc/uac-3pcc-C-B.xml) 

The whole scenario need 2 SIPp instances in communication trough the [3PCC](http://sipp.sourceforge.net/doc/reference.html#3PCC) SIPp feature.

* `Call-pickup-3pcc/uac-3pcc-C-A.xml` is the scenario controlling the first SIPp instance (A)
* `Call-pickup-3pcc/uac-3pcc-C-B.xml` is the scenario controlling the second SIPp instance (B)

The whole scenario can be described with the following steps:

1. Instance **A** starts a call with DUT
2. As soon **DUT** answers the call, instance **B** sends a new INVITE containing the *Replaces* header, the header must contain the `Call-ID` and the local and remote tags of the first dialog (see the previous point)
3. Now **DUT** should terminate the first dialog (replaced by the new one). The caller ID should be updated
4. **DUT** should answer the call
5. Now instance B waits for a `BYE` from the phone

#### Message diagram

```
DUT                         A(uac-3pcc-C-A.xml)                     B(uac-3pcc-C-B.xml)
 |    INVITE                |                                       |
 |<-------------------------|                                       |
 |                          |                                       |
 |    180 Ringing           |                                       |
 |------------------------->|                                       |
 |                          |                                       |
 |                          |  Cmd (Call-ID,local-tag,remote-tag)   |
 |                          |-------------------------------------->|
 |    INVITE (Replaces)     |                                       |
 |<-----------------------------------------------------------------|
 |                          |                                       |
 |     BYE                  |                                       |
 |------------------------->|                                       |
 |                          |                                       |
 |    200 OK                |                                       |
 |<-------------------------|                                       |
 |                          |                                       |
 | 200 OK                   |                                       |
 |----------------------------------------------------------------->|
 |                          |                                       |
 |    BYE                   |                                       |
 |----------------------------------------------------------------->|
 |                          |                                       |
 |    200 OK                |                                       |
 |<-----------------------------------------------------------------|
 |                          |                                       |     
```

The 3PCC feature is designed to reuse the same Call-ID of the first call (adding the Call-ID header in the *sendCmd* is mandatory), but in this scenario we need to instantiate a new SIP dialog, for this reason we add the prefix *new-* into the header value.

### How to use

1) You have to start the SIPp instance **B**, assuming that:

 * *172.16.18.15* is your computer address
 * you want to receive the messages from instance **A** to the port *7777*
 * *172.16.18.64* is DUT (Device Under Test)
 * *382* is the DUT extension

 ```
 sipp -p 5061 -sf Call-pickup-3pcc/uac-3pcc-C-B.xml -s 382 -3pcc 127.0.0.1:7777 -i 172.16.18.15 -mi 172.16.18.15 -m 1 172.16.18.64
 ```
 
 Once instance started SIPp will wait for the command from instance **A**

2) Start the instance **A**, assuming that:

 * *172.16.18.15* is your computer address
 * you want to send the messages to instance **B** to the port *7777*
 * *172.16.18.64* is DUT
 * *382* is the DUT extension
 
 ```
 sipp -p 5062 -sf Call-pickup-3pcc/uac-3pcc-C-A.xml -s 382 -3pcc 127.0.0.1:7777 -i 172.16.18.15 -mi 172.16.18.15 -m 1 172.16.18.64
 ```
 
3) At this point DUT should ring, once you answer the call instance **A** should exit and the call should be terminated on instance **B**

**NOTE: if *DUT* is a Snom phone and you want to automate the call answer last point you can de-comment the following action:**

```xml
  <nop display="Remotely answering pressing the ENTER key">
   <action>
     <exec command="curl -s http://[remote_ip]/command.htm?key=ENTER > /dev/null"/>
   </action>
  </nop>
```
