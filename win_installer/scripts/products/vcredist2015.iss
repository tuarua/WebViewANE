; requires Windows 10, Windows 7 Service Pack 1, Windows 8, Windows 8.1, Windows Server 2003 Service Pack 2, Windows Server 2008 R2 SP1, Windows Server 2008 Service Pack 2, Windows Server 2012, Windows Vista Service Pack 2, Windows XP Service Pack 3
; http://www.microsoft.com/en-us/download/details.aspx?id=48145

[CustomMessages]
vcredist2015_title=Visual C++ 2015-2022 Redistributable 32-Bit
vcredist2015_title_x64=Visual C++ 2015-2022 Redistributable 64-Bit

vcredist2015_size=13.1 MB
vcredist2015_size_x64=24.1 MB

[Code]
const
	vcredist2015_url = 'https://aka.ms/vs/17/release/vc_redist.x86.exe';
	vcredist2015_url_x64 = 'https://aka.ms/vs/17/release/vc_redist.x64.exe';

	vcredist2015_upgradecode = '{65E5BD06-6392-3027-8C26-853107D3CF1A}';
	vcredist2015_upgradecode_x64 = '{36F68A90-239C-34DF-B58C-64B30153CE35}';

procedure vcredist2015(minVersion: string);
begin
	if (not IsIA64()) then begin
		if (not msiproductupgrade(GetString(vcredist2015_upgradecode, vcredist2015_upgradecode_x64, ''), minVersion)) then
			AddProduct('vcredist2015' + GetArchitectureString() + '.exe',
				'/passive /norestart',
				CustomMessage('vcredist2015_title' + GetArchitectureString()),
				CustomMessage('vcredist2015_size' + GetArchitectureString()),
				GetString(vcredist2015_url, vcredist2015_url_x64, ''),
				false, false, false);
	end;
end;

[Setup]
