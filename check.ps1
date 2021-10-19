#(gwmi win32_pnpEntity -Filter 'manufacturer like "Red Hat%"')[5].getDeviceProperties().deviceproperties | ft keyName,data
(gwmi win32_pnpEntity -Filter 'PNPClass like "Display%"').getDeviceProperties().deviceproperties | ft keyName,data
