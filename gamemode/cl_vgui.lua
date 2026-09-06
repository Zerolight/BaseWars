if( VoteVGUI ) then

	for k, v in pairs( VoteVGUI ) do

		v:Remove();
		VoteVGUI[k] = nil;

	end

end

VoteVGUI = { }
PanelNum = 0;

if( LetterWritePanel ) then

	LetterWritePanel:Remove();
	LetterWritePanel = nil;

end

