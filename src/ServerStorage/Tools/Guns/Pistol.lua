local Tool = script:WaitForChild("Pistol")

return function(Resources, ToolInfo, Player)
	return Resources["Gun_System"].Setup(Player, Tool, ToolInfo, {
		
	})
end