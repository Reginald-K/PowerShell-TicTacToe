<#
Project by Reginald_K
Date of creation: 18.10.2023
Date of release: 25.10.2023
Version: 1.6

                 /\        /\
                / /        \ \
               / /          \ \
               \ \          / /
        /\      \ \        / /      /\
        \ \      \ \______/ /      / /
         \ \      \/  __  \/      / /
          \ \_____/   ||   \_____/ /
           \_____/  __||__  \_____/
          ______/   |_  _|   \______
         / _____\     ||     /_____ \
        / /     /\    ||    /\     \ \
       / /     / /\________/\ \     \ \
      / /     / / /        \ \ \     \ \
      \/     / / / O O  O O \ \ \     \/
            / /  \()()  ()()/  \ \
            \ \   \________/   / /
             \ \   {{    }}   / /
              \ \            / /
               \/            \/

.Description
    Ein Tic-Tac-Toe Spiel, bei dem auch Computergegner verschiedener Schwierigkeitsstufen vorhanden sind.

.Notes
    Features:
        Ein Hauptmenü Fenster.
        Lokaler Multiplayer.
        Ein Beenden Button im Hauptmenü.
        Spiele werden im separaten Fenster geöffnet.
        Spiel gegen den Computer mit 5 Stufen der KI.
        4 Stufen sind in einem Untermenü versteckt um mehr Übersichtlichkeit zu erreichen.
        Alle Spiele gegen KIs können als X oder O gespielt werden.
        Statusaneige im Spielfenster.
        Feldgröße im Hauptmenü konfigurierbar.
        Konfiguration erfolgt in einem Untermenü.
        Hintergrundbild (Update 1.1)
        Konfigurationsmenü hat einen Beenden Button (Update 1.2)
        Spielfenster hat einen Beenden Button (Update 1.3)
        Insets werden bei der Fenstergröße berücksichtigt (Update 1.4)
        Menüs sind Konfigurierbar (Update 1.5)
    Konfiguration:
        Momentan nur zwei Konfigurationen erstellt, aber der Grundstein für Erweiterungen wurde bereits gelegt.
        Konfiguration nur für das Spielfeld möglich.
        Konfiguration berücksichtigt nicht Insets.
        Konfiguration des Spielfensters in separate Klasse ausgelagert.
        Konfigurationsklassen können ergenzt werden.
    Ideen für Erweiterungen:
        Mehr Konfigurationen erstellen.
        Konfigurationen in CSV auslagern.
        Spiel zur Laufzeit Konfigurierbar machen.
        Performance für Hintergrundbilder verbessern.
        Individuelle Hintergrundbilder für individuelle Fenster einfügen.
        Bilder in Buttons einfügen.
        Hintergrundmusik.
        Fenster mit den Spielregeln.
        Mehr Elemente in Objekte auslagern.
        Vererbungen von Klassen.
        Spiel Abbrechen bei feritigem Spiel durch einen anderen Text ersetzen.
        Konfigurationsmenü umstrukturieren.
#>

# Instanzierung ####################################################################################
# Imports ------------------------------------------------------------------------------------------

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

# Grafiken laden -----------------------------------------------------------------------------------

$background = [System.Drawing.Image]::FromFile(".\rw2.png")

####################################################################################################


# Ui Funktionen ####################################################################################
# Standardelemente Erstellen -----------------------------------------------------------------------

# Erstellt ein Standardkonfiguriertes Fenster.
Function Create-Window
    {
        param(
            [parameter(position=0)][Int]$width = 400,
            [parameter(position=1)][Int]$height = 400,
            [parameter(position=2)][String]$name = "New Window"
        )
        $window = New-Object System.Windows.Forms.Form
        $window.StartPosition = "CenterScreen"
        Resize-Window $width $height $window
        $window.Text = $name
        $window.BackgroundImage = $background
        return $window
    }

# Erstellt ein Standardkonfiguriertes Label ohne Größe und Position.
Function Create-Label
    {
        param(
            [Int]$FontSize = $ConfigurationMenu.getConfig().FONT_SIZE
        )
        $label = New-Object System.Windows.Forms.Label
        $label.BackColor = [System.Drawing.Color]::FromName("Transparent")
        $label.AutoSize = $false
        $label.TextAlign = "MiddleCenter"
        $label.font = New-Object System.Drawing.Font ("Arial", $FontSize, [System.Drawing.Fontstyle]::Bold)
        return $label
    }

# Erstellt einen Standardkonfigurierten Button ohne Größe und Position.
Function Create-Button
    {
        param(
            [Int]$FontSize = $ConfigurationMenu.getConfig().FONT_SIZE
        )
        $button = New-Object System.Windows.Forms.Button
        $button.AutoSize = $false
        $button.TextAlign = "MiddleCenter"
        $button.font = New-Object System.Drawing.Font ("Arial", $FontSize, [System.Drawing.Fontstyle]::Bold)
        return $button
    }

# Elemente Formatieren -----------------------------------------------------------------------------

# Positioniert ein Element.
Function Position-Element
    {
        param(
            [parameter(position=0)]$element,
            [parameter(position=1)][Int]$xpos = 50,
            [parameter(position=2)][Int]$ypos = 50
        )
        $element.Location = New-Object System.Drawing.Size ($xpos, $ypos)
    }

# Definiert oder ändert die Größe eines Elements.
Function Resize-Element
    {
        param(
            [parameter(position=0)]$element,
            [parameter(position=1)][Int]$width = 50,
            [parameter(position=2)][Int]$height = 50
        )
        $element.Size = New-Object System.Drawing.Size ($width, $height)
    }

# Definiert oder ändert die Größe eines Fensters.
Function Resize-Window
    {
        param(
            [parameter(position=0)][Int]$width = 600,
            [parameter(position=1)][Int]$height = 600,
            [parameter(position=2)]$window
        )
        $window.Size = New-Object System.Drawing.Size ($width, $height)
        $Inset_width = $width - $window.ClientSize.Width
        $Inset_height = $height - $window.ClientSize.Height
        $window.Size = New-Object System.Drawing.Size (($width + $Inset_width), ($height + $Inset_height))
    }

####################################################################################################


# Klassen ##########################################################################################
# Spielfeld-Config ---------------------------------------------------------------------------------

# Konfiguration des Fensters wurde Ausgelagert, um die Änderung des Designs zu vereinfachen.
class FeldConfigGross
    {
        # Konstanten -------------------------------------------
        <#
            MARGIN_WINDOW:   Abstand, den Alle Elemente zum Fensterrand haben sollen.
            MARGIN_BOTTOM:   Zusätzlicher Freiraum, den das Fenster unten benötigt.
            HEADLINE_HEIGHT: Höhe der Überschrift
            BUTTON_SIZE:     Größe der Knöpfe
            MARGIN_OBJECT:   Abstand, den Objekte zueinander waren sollen.
        #>
        $MARGIN_WINDOW = 50
        $HEADLINE_HEIGHT = 30
        $BUTTON_SIZE = 80
        $MARGIN_OBJECT = 20
        $FONT_SIZE = 14
        $SYMBOL_SIZE = 28
    }

# Konfiguration des für ein kleineres Design.
class FeldConfigKlein
    {
        # Konstanten -------------------------------------------
        <#
            MARGIN_WINDOW:   Abstand, den Alle Elemente zum Fensterrand haben sollen.
            MARGIN_BOTTOM:   Zusätzlicher Freiraum, den das Fenster unten benötigt.
            HEADLINE_HEIGHT: Höhe der Überschrift
            BUTTON_SIZE:     Größe der Knöpfe
            MARGIN_OBJECT:   Abstand, den Objekte zueinander waren sollen.
            FONT_SIZE:       Größe der Schrift des Textes.
        #>
        $MARGIN_WINDOW = 40
        $HEADLINE_HEIGHT = 40
        $BUTTON_SIZE = 50
        $MARGIN_OBJECT = 15
        $FONT_SIZE = 14
        $SYMBOL_SIZE = 22
    }

# Enthält Konfiguration für Menü
class MenuConfigKlein
    {
        $MARGIN_WINDOW = 70
        $OBJECT_HEIGHT = 40
        $OBJECT_WIDTH = 400
        $MARGIN_OBJECT = 10
        $FONT_SIZE = 12
    }

# Enthält Konfiguration für Menü
class MenuConfigGross
    {
        $MARGIN_WINDOW = 90
        $OBJECT_HEIGHT = 50
        $OBJECT_WIDTH = 450
        $MARGIN_OBJECT = 15
        $FONT_SIZE = 18
    }

# Eigene Variable, welche die Konfig hält.
class FeldConfig
    {
        [int]$id = 0
        $ConfigArray = @([FeldConfigGross]::new(), [FeldConfigKlein]::new())

        [Object]getConfig()
            {
                return $this.ConfigArray[$this.id]
            }

        [void]changeConfig()
            {
                if($this.id -eq 0)
                    {
                        $this.id = 1
                    }
                else
                    {
                        $this.id = 0
                    }
            }
    }

class MenuConfig
    {
        [int]$id = 0
        $ConfigArray = @([MenuConfigGross]::new(), [MenuConfigKlein]::new())

        [Object]getConfig()
            {
                return $this.ConfigArray[$this.id]
            }

        [void]changeConfig()
            {
                if($this.id -eq 0)
                    {
                        $this.id = 1
                    }
                else
                    {
                        $this.id = 0
                    }
            }
    }

# Fenster ------------------------------------------------------------------------------------------

# Hauptfenster
class MainWindow
    {
        $MWindow = 0
        $NoElements = 7
        $Config = 0
        $Label = 0
        $Button1 = 0
        $Button2 = 0
        $Button3 = 0
        $Button4 = 0
        $Button5 = 0
        $Button6 = 0

        MainWindow()
            {
                $this.Config = $Script:ConfigurationMenu.getConfig()
                $Width = $this.CalculateWindowWidth()
                $Height = $this.CalculateWindowHeight()

                $this.MWindow = Create-Window $Width $Height "Spielauswahl"

                # Label mit der Überschrift des Menüs ------------------
                $this.Label = Create-Label
                $this.Format_Element($this.Label, 1)
                $this.Label.text = "Was möchten Sie tun?"
                $this.MWindow.Controls.Add($this.Label)

                # Lokaler Mehrspieler ----------------------------------
                $this.Button1 = Create-Button
                $this.Format_Element($this.Button1, 2)
                $this.Button1.text = "Mensch gegen Mensch spielen"
                $this.Button1.add_click({
                    Open-Gamewindow 0
                })
                $this.MWindow.Controls.Add($this.Button1)

                # Spiel gegen AI5 als X --------------------------------
                $this.Button2 = Create-Button
                $this.Format_Element($this.Button2, 3)
                $this.Button2.text = "Gegen Maschine 6 als X spielen"
                $this.Button2.add_click({
                    Open-Gamewindow 6 1
                })
                $this.MWindow.Controls.Add($this.Button2)

                # Spiel gegen AI5 als O --------------------------------
                $this.Button3 = Create-Button
                $this.Format_Element($this.Button3, 4)
                $this.Button3.text = "Gegen Maschine 6 als O spielen"
                $this.Button3.add_click({
                    Open-Gamewindow 6 2
                })
                $this.MWindow.Controls.Add($this.Button3)

                # Untermenü mit anderen Computergegnern ----------------
                $this.Button4 = Create-Button
                $this.Format_Element($this.Button4, 5)
                $this.Button4.text = "Gegen Vorgängerversionen spielen"
                $this.Button4.add_click({
                    Open-Submenu
                })
                $this.MWindow.Controls.Add($this.Button4)

                # Konfiguration Ändern ---------------------------------
                $this.Button5 = Create-Button
                $this.Format_Element($this.Button5, 6)
                $this.Button5.text = "Konfiguration Ändern"
                $this.Button5.add_click({
                    #$Script:ConfigurationWindow = [ConfigWindow]::new()
                    #$Script:ConfigurationWindow.show()
                    Open-Configmenu
                })
                $this.MWindow.Controls.Add($this.Button5)

                # Beenden Button ---------------------------------------
                $this.Button6 = Create-Button
                $this.Format_Element($this.Button6, 7)
                $this.Button6.text = "Beenden"
                $this.Button6.add_click({
                    $Script:Hauptfenster.MWindow.Close()
                })
                $this.MWindow.Controls.Add($this.Button6)
            }

        [void]Refresh()
            {
                # Update Config
                $this.Config = $Script:ConfigurationMenu.getConfig()

                # Recalculating new Window size
                $Width = ($this.Config.MARGIN_WINDOW * 2) + $this.Config.OBJECT_WIDTH
                $Height = ($this.Config.MARGIN_WINDOW * 2) + ($this.Config.OBJECT_HEIGHT * $this.NoElements) + ($this.Config.MARGIN_OBJECT * ($this.NoElements - 1))

                # Applying new Window size
                Resize-Window $Width $Height $this.MWindow

                # Updating Elements
                $this.Format_Element($this.Label, 1)
                $this.Format_Element($this.Button1, 2)
                $this.Format_Element($this.Button2, 3)
                $this.Format_Element($this.Button3, 4)
                $this.Format_Element($this.Button4, 5)
                $this.Format_Element($this.Button5, 6)
                $this.Format_Element($this.Button6, 7)

                # Updating Font size
                $this.Label.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.Button1.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.Button2.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.Button3.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.Button4.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.Button5.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.Button6.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
            }

        [void]Format_Element($element, $position)
            {
                $ypos = $this.Config.MARGIN_WINDOW + ($this.Config.OBJECT_HEIGHT + $this.Config.MARGIN_OBJECT) * ($position - 1)
                Position-Element $element $this.Config.MARGIN_WINDOW $ypos
                Resize-Element $element $this.Config.OBJECT_WIDTH $this.Config.OBJECT_HEIGHT
            }

        [void]Show()
            {
                [void] $this.MWindow.ShowDialog()
            }

        [void]Close()
            {
                $this.MWindow.Close()
            }

        [Int]CalculateWindowWidth()
            {
                return ( ($this.Config.MARGIN_WINDOW * 2) + $this.Config.OBJECT_WIDTH )
            }

        [Int]CalculateWindowHeight()
            {
                return ( ($this.Config.MARGIN_WINDOW * 2) + ($this.Config.OBJECT_HEIGHT * $this.NoElements) + ($this.Config.MARGIN_OBJECT * ($this.NoElements - 1)) )
            }
    }

# Hält das Fenster mit dem Spielfeld.
class Feld
    {
        # Variablen --------------------------------------------
        <#
            Spielfenster: Fensterinstanz.
            FeldButtons:  Doppeltes Array mit Buttons
            FeldInhalte:  Doppeltes Array mit den Einträgen des Feldes.
            Spielinfo:    Label mit der Übershcrift.
            TurnCounter:  Zugzähler. Wird auch zur Ermittlung des Zugspielers verwendet.
            Ended:        Kommunikationsschnittstelle die aussagt, ob das Spiel beendet ist.
        #>
        $Config = 0
        $Spielfenster = 0
        $FeldButtons = @(@(0,0,0), @(0,0,0), @(0,0,0))
        $FeldInhalte = @(@(0,0,0), @(0,0,0), @(0,0,0))
        $FeldButtonEnd = 0
        $Spielinfo = 0
        $TurnCounter = 0
        [bool]$Ended = $false

        # Konstruktor ------------------------------------------
        Feld()
            {
                # Config
                $this.Config = $Script:ConfigurationFeld.getConfig()
                <#
                    Das Fenster muss breit genug sein um Folgenes zu halten:
                        Window margin links und rechts.
                        3 Buttons.
                        2 Margins zwischen den Buttons.
                #>
                $window_width = 2 * $this.Config.MARGIN_WINDOW + 3* $this.Config.BUTTON_SIZE + 2 * $this.Config.MARGIN_OBJECT
                <#
                    Das Fenster muss hoch genug sein um Folgenes zu halten:
                        Window margin oben und unten.
                        2 Headline höhe (1 für die Headline und 1 für den Beenden Button).
                        3 Buttons.
                        4 Margins zwischen Objekten den Buttons.
                #>
                $window_height = 2 * $this.Config.MARGIN_WINDOW + 3* $this.Config.BUTTON_SIZE + 4 * $this.Config.MARGIN_OBJECT + 2 * $this.Config.HEADLINE_HEIGHT

                # Fenster
                $this.Spielfenster = Create-Window $window_width $window_height "Game Window"

                #Label
                $Spielinfo_width = $window_width - 2 * $this.Config.MARGIN_WINDOW
                $this.Spielinfo = Create-Label -FontSize $this.Config.FONT_SIZE
                Position-Element $this.Spielinfo $this.Config.MARGIN_WINDOW $this.Config.MARGIN_WINDOW
                Resize-Element $this.Spielinfo $Spielinfo_width $this.Config.HEADLINE_HEIGHT
                $this.Spielinfo.text = "X ist am Zug"
                $this.Spielfenster.Controls.Add($this.Spielinfo)

                # Spielfelder
                $this.CreateField()

                # Beenden Button
                $FeldButtonEnd_ypos = $window_height - $this.Config.MARGIN_WINDOW - $this.Config.HEADLINE_HEIGHT
                $this.FeldButtonEnd = Create-Button -FontSize $this.Config.FONT_SIZE
                Position-Element $this.FeldButtonEnd $this.Config.MARGIN_WINDOW $FeldButtonEnd_ypos
                Resize-Element $this.FeldButtonEnd $Spielinfo_width $this.Config.HEADLINE_HEIGHT
                $this.FeldButtonEnd.text = "Spiel Abbrechen"
                $this.FeldButtonEnd.add_click({
                    $Script:Spielfenster.Spielfenster.Close()
                })
                $this.Spielfenster.Controls.Add($this.FeldButtonEnd)
            }

        # Erstellung der 9 Buttons wurde aus dem Konstruktor ausgelagert.
        # Fungiert aber als private Methode des Konstruktors.
        [void]CreateField()
            {
                FOR ($i = 0; $i -lt 3; $i++)
     	            {
                        FOR ($j = 0; $j -lt 3; $j++)
                            {
                                # Erstellung der Buttons -------------------------------
                                $xpos = $this.Config.MARGIN_WINDOW + $i * ($this.Config.BUTTON_SIZE + $this.Config.MARGIN_OBJECT)
                                $ypos = ($this.Config.MARGIN_WINDOW + $this.Config.HEADLINE_HEIGHT + $this.Config.MARGIN_OBJECT) + $j * ($this.Config.BUTTON_SIZE + $this.Config.MARGIN_OBJECT)
                                $button = Create-Button -FontSize $this.Config.SYMBOL_SIZE
                                Position-Element $button $xpos $ypos
                                Resize-Element $button $this.Config.BUTTON_SIZE $this.Config.BUTTON_SIZE

                                # Verknüpfung der Buttons mit der Logik ----------------
                                <#
                                    Der Button kann nicht mit this. auf Funktionen innerhalb dieser Klasse zugreifen.
                                    Statdessen enthält jeder Button eine ID, die eindeutig zu seiner Position ist.
                                    Mithilfe dieser ID wird die Position gespeichert, die sonst verloren gehen würde.
                                    Diese ID wird dann an eine Funktion im Skript gesendet.
                                    Die Funktion im Skript greift auf dieses Objekt zu und verwendet die Place() Methode.
                                #>
                                $id = 10 * $i + $j
                                $button.Tag = $id
                                $button.add_click({
                                    $coordinaten = $this.Tag
                                    [Int]$spalte = $coordinaten/10
                                    [Int]$zeile = $coordinaten % 10
                                    Perform-Action -x $spalte -y $zeile
                                })
                    
                                # Einbinden der Buttons --------------------------------
                                $this.FeldButtons[$i][$j] = $button
                                $this.Spielfenster.Controls.Add($button)
                            }
                    }
            }

        # Methoden ---------------------------------------------

        # Anzeige des Fensters. Kann aufgrund der eigenarten der Library nicht im Konstruktor stehen.
        [void]Show()
            {
                [void] $this.Spielfenster.ShowDialog()
            }
            
        [void]Close()
            {
                $this.Spielfenster.Close()
            }

        # Plazierung eines Symbols in ein Feld.
        [void]Place($x, $y)
            {
                if($this.TurnCounter % 2 -eq 0)
                    {
                        # X ist am Zug
                        $this.FeldInhalte[$x][$y] = 1
                        $this.FeldButtons[$x][$y].text = "X"
                        #$this.FeldButtons[$x][$y].text = $this.TurnCounter + 1
                    }
                else
                    {
                        # O ist am Zug
                        $this.FeldInhalte[$x][$y] = 2
                        $this.FeldButtons[$x][$y].text = "O"
                        #$this.FeldButtons[$x][$y].text = $this.TurnCounter + 1
                    }

                $this.AfterTurn($x, $y)
            }

        # Private Funktion von Place(). Logik, die nach jedem Zug ausgeführt werden muss.
        [void]AfterTurn($x, $y)
            {
                $this.FeldButtons[$x][$y].Enabled = $false
                $this.TurnCounter++

                # Ändern der Überschrift um den richtigen Zugspieler zu repräsentieren.
                if(($this.TurnCounter % 2) -eq 1)
                    {
                        $this.Spielinfo.text = "O ist am Zug"
                    }
                else
                    {
                        $this.Spielinfo.text = "X ist am Zug"
                    }

                # Prüfung, ob das Spiel vorbei ist.
                if ($this.CheckGameOver($x, $y))
                    {
                        $this.EndGame($this.FeldInhalte[$x][$y])
                    }
                elseif ($this.CheckStalemate())
                    {
                        $this.Stalemate()
                    }
            }

        # Private Funktion, wenn das Spiel aufgrund eines Spieges fertig ist.
        [void]EndGame($winner)
            {
                # Spiel für die Schnittstelle als beendet markieren.
                $this.Ended = $true

                # Fortsetzen des Spieles verhindern.
                FOR ($i = 0; $i -lt 3; $i++)
     	            {
                        FOR ($j = 0; $j -lt 3; $j++)
                            {
                                $this.FeldButtons[$i][$j].Enabled = $false
                            }
                    }

                # Bekanntgabe des Gewinners.
                if($winner -eq 1)
                    {
                        $this.Spielinfo.text = "X hat gewonnen"
                    }
                else
                    {
                        # Es wäre möglich zu überprüfen, ob O tatsächlich gewonnen hat oder ob ein Bug vorliegt.
                        # Wird in diesem Fall aber nicht gemacht.
                        $this.Spielinfo.text = "O hat gewonnen"
                    }
            }

        # Private Funktion, wenn das Spiel ohne Sieger endet.
        [void]Stalemate()
            {
                $this.Ended = $true
                $this.Spielinfo.text = "Das Spiel ist beendet"
            }

        
        # Funktionen -------------------------------------------
        
        # Überprüft, ob das Spiel gewonnen wurde.
        [bool]CheckGameover($x, $y)
            {
                if ($this.CheckLine($x, $y))
                    {
                        return $true
                    }
                elseif ($this.CheckColumn($x, $y))
                    {
                        return $true
                    }
                elseif ($this.CheckDiagonals($x, $y))
                    {
                        return $true
                    }
                else
                    {
                        return $false
                    }
            }

        # Überprüft, ob das Spiel in der aktuellen Zeile gewonnen wurde.
        [bool]CheckLine($x, $y)
            {
                if($this.FeldInhalte[0][$y] -eq $this.FeldInhalte[1][$y] -and $this.FeldInhalte[1][$y] -eq $this.FeldInhalte[2][$y])
                    {
                        return $true
                    }
                else
                    {
                        return $false
                    }
            }

        # Überprüft, ob das Spiel in der aktuellen Spalte gewonnen wurde.
        [bool]CheckColumn($x, $y)
            {
                if($this.FeldInhalte[$x][0] -eq $this.FeldInhalte[$x][1] -and $this.FeldInhalte[$x][1] -eq $this.FeldInhalte[$x][2])
                    {
                        return $true
                    }
                else
                    {
                        return $false
                    }
            }

        # Überprüft, ob das Spiel in einer Diagonalen gewonnen wurde.
        [bool]CheckDiagonals($x, $y)
            {
                $sum = $x + $y
                # Wenn die Summe der beiden Koordinaten nicht gerade ist, liegt man nicht auf einer Diagonalen.
                # Alle Diagonalen laufen durch die Mitte. Wenn diese also leer ist, ist keine Diagonale gefüllt.
                if ($sum %2 -eq 0 -and $this.FeldInhalte[1][1] -ne 0)
                    {
                        if ($this.FeldInhalte[0][0] -eq $this.FeldInhalte[1][1] -and $this.FeldInhalte[1][1] -eq $this.FeldInhalte[2][2])
                            {
                                return $true
                            }
                        elseif ($this.FeldInhalte[0][2] -eq $this.FeldInhalte[1][1] -and $this.FeldInhalte[1][1] -eq $this.FeldInhalte[2][0])
                            {
                                return $true
                            }
                        else
                            {
                                return $false
                            }
                    }
                else
                    {
                        return $false
                    }
            }

        # Überprüft, ob ein Unentschieden erreicht wurde.
        [bool]CheckStalemate()
            {
                if ($this.TurnCounter -ge 9)
                    {
                        return $true
                    }
                else
                    {
                        return $false
                    }
            }

    }

# Fenster mit den Knofigurationseinstellungen.
class ConfigWindow
    {
        $Window = 0
        $Clabel1 = 0
        $CButton1 = 0
        $CButton2 = 0
        $Clabel2 = 0
        $CButton3 = 0
        $CButton4 = 0
        $CButtonEnd = 0
        $NoElements = 7
        $Config = 0
        ConfigWindow()
            {
                $this.Config = $Script:ConfigurationMenu.getConfig()
                $Width = ($this.Config.MARGIN_WINDOW * 2) + $this.Config.OBJECT_WIDTH
                $Height = ($this.Config.MARGIN_WINDOW * 2) + ($this.Config.OBJECT_HEIGHT * $this.NoElements) + ($this.Config.MARGIN_OBJECT * ($this.NoElements - 1))

                $this.Window = Create-Window $Width $Height "Konfiguration"
                
                # Label mit Anzeige der Feldkonfiguration --------------
                $this.Clabel1 = Create-Label
                $this.Format_Element($this.Clabel1, 1)
                $this.Clabel1.text = ""
                $this.Window.Controls.Add($this.Clabel1)
                
                # Konfiguration auf groß Stellen -----------------------
                $this.CButton1 = Create-Button
                $this.Format_Element($this.CButton1, 2)
                $this.CButton1.text = "Feldgröße auf groß ändern"
                $this.CButton1.add_click({
                    $Script:ConfigurationFeld.changeConfig()
                    $Script:ConfigurationWindow.update()
                })
                $this.Window.Controls.Add($this.CButton1)

                # Konfiguration auf klein Stellen ----------------------
                $this.CButton2 = Create-Button
                $this.Format_Element($this.CButton2, 3)
                $this.CButton2.text = "Feldgröße auf klein ändern"
                $this.CButton2.add_click({
                    $Script:ConfigurationFeld.changeConfig()
                    $Script:ConfigurationWindow.update()
                })
                $this.Window.Controls.Add($this.CButton2)
                
                # Label mit Anzeige der Menükonfiguration --------------
                $this.Clabel2 = Create-Label
                $this.Format_Element($this.Clabel2, 4)
                $this.Clabel2.text = ""
                $this.Window.Controls.Add($this.Clabel2)

                # Konfiguration auf groß Stellen -----------------------
                $this.CButton3 = Create-Button
                $this.Format_Element($this.CButton3, 5)
                $this.CButton3.text = "Menügröße auf groß ändern"
                $this.CButton3.add_click({
                    $Script:ConfigurationMenu.changeConfig()
                    $Script:ConfigurationWindow.update()
                    $Script:ConfigurationWindow.Refresh()
                })
                $this.Window.Controls.Add($this.CButton3)

                # Konfiguration auf klein Stellen ----------------------
                $this.CButton4 = Create-Button
                $this.Format_Element($this.CButton4, 6)
                $this.CButton4.text = "Menügröße auf klein ändern"
                $this.CButton4.add_click({
                    $Script:ConfigurationMenu.changeConfig()
                    $Script:ConfigurationWindow.update()
                    $Script:ConfigurationWindow.Refresh()
                })
                $this.Window.Controls.Add($this.CButton4)

                # Beenden ----------------------------------------------
                $this.CButtonEnd = Create-Button
                $this.Format_Element($this.CButtonEnd, 7)
                $this.CButtonEnd.text = "Zurück zum Hauptmenü"
                $this.CButtonEnd.add_click({
                    #Open-Mainwindow
                    #$Script:ConfigurationWindow.Window.Close()
                    Close-Configmenu
                })
                $this.Window.Controls.Add($this.CButtonEnd)

                # Initialeinstellungen ---------------------------------
                $this.update()
            }

        [void]show()
            {
                $this.Window.ShowDialog()
            }
            
        [void]Close()
            {
                Write-Host "Schließen"
                $this.Window.Close()
                Write-Host "Geschlossen"
            }

        [void]update()
            {
                if($Script:ConfigurationFeld.id -eq 0)
                    {
                        $this.Clabel1.text = "Feldgröße ist derzeit groß"
                        $this.CButton1.Enabled = $false
                        $this.CButton2.Enabled = $true
                    }
                elseif($Script:ConfigurationFeld.id -eq 1)
                    {
                        $this.Clabel1.text = "Feldgröße ist derzeit klein"
                        $this.CButton1.Enabled = $true
                        $this.CButton2.Enabled = $false
                    }

                if($Script:ConfigurationMenu.id -eq 0)
                    {
                        $this.Clabel2.text = "Menügröße ist derzeit groß"
                        $this.CButton3.Enabled = $false
                        $this.CButton4.Enabled = $true
                    }
                elseif($Script:ConfigurationMenu.id -eq 1)
                    {
                        $this.Clabel2.text = "Menügröße ist derzeit klein"
                        $this.CButton3.Enabled = $true
                        $this.CButton4.Enabled = $false
                    }
            }

        [void]Refresh()
            {
                # Update Config
                $this.Config = $Script:ConfigurationMenu.getConfig()

                # Recalculating new Window size
                $Width = ($this.Config.MARGIN_WINDOW * 2) + $this.Config.OBJECT_WIDTH
                $Height = ($this.Config.MARGIN_WINDOW * 2) + ($this.Config.OBJECT_HEIGHT * $this.NoElements) + ($this.Config.MARGIN_OBJECT * ($this.NoElements - 1))

                # Applying new Window size
                $this.Window.Size = New-Object System.Drawing.Size ($width, $height)
                $Inset_width = $width - $this.Window.ClientSize.Width
                $Inset_height = $height - $this.Window.ClientSize.Height
                $this.Window.Size = New-Object System.Drawing.Size (($width + $Inset_width), ($height + $Inset_height))

                # Updating Elements
                $this.Format_Element($this.Clabel1, 1)
                $this.Format_Element($this.CButton1, 2)
                $this.Format_Element($this.CButton2, 3)
                $this.Format_Element($this.Clabel2, 4)
                $this.Format_Element($this.CButton3, 5)
                $this.Format_Element($this.CButton4, 6)
                $this.Format_Element($this.CButtonEnd, 7)

                # Updating Font size
                $this.Clabel1.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.CButton1.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.CButton2.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.Clabel2.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.CButton3.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.CButton4.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
                $this.CButtonEnd.font = New-Object System.Drawing.Font ("Arial", $this.Config.FONT_SIZE, [System.Drawing.Fontstyle]::Bold)
            }

        [void]Format_Element($element, $position)
            {
                $ypos = $this.Config.MARGIN_WINDOW + ($this.Config.OBJECT_HEIGHT + $this.Config.MARGIN_OBJECT) * ($position - 1)
                Position-Element $element $this.Config.MARGIN_WINDOW $ypos
                Resize-Element $element $this.Config.OBJECT_WIDTH $this.Config.OBJECT_HEIGHT
            }
    }

class SubmenuWindow
    {
        $Window = 0
        $NoElements = 10
        $Config = 0

        SubmenuWindow()
        {
            $this.Config = $Script:ConfigurationMenu.getConfig()
            
            # Fenster erstellen ------------------------------------
            $Width = ($this.Config.MARGIN_WINDOW * 2) + $this.Config.OBJECT_WIDTH
            $Height = ($this.Config.MARGIN_WINDOW * 2) + ($this.Config.OBJECT_HEIGHT * $this.NoElements) + ($this.Config.MARGIN_OBJECT * ($this.NoElements - 1))
            $this.Window = Create-Window $Width $Height "AI Tester"

            # Label mit der Überschrift des Menüs ------------------
            $label = Create-Label
            $this.Format_Element($label, 1)
            $label.text = "Wählen Sie eine Version"
            $this.Window.Controls.Add($label)

            # AI1 X Button erstellen -------------------------------
            $Spiel2 = Create-Button
            $this.Format_Element($Spiel2, 2)
            $Spiel2.text = "Gegen Maschine 1 als X spielen"
            $Spiel2.add_click({
                Open-Gamewindow 1 1
            })
            $this.Window.Controls.Add($Spiel2)

            # AI1 O Button erstellen -------------------------------
            $Spiel3 = Create-Button
            $this.Format_Element($Spiel3, 3)
            $Spiel3.text = "Gegen Maschine 1 als O spielen"
            $Spiel3.add_click({
                Open-Gamewindow 1 2
            })
            $this.Window.Controls.Add($Spiel3)

            # AI2 X Button erstellen -------------------------------
            $Spiel4 = Create-Button
            $this.Format_Element($Spiel4, 4)
            $Spiel4.text = "Gegen Maschine 2 als X spielen"
            $Spiel4.add_click({
                Open-Gamewindow 2 1
            })
            $this.Window.Controls.Add($Spiel4)

            # AI2 O Button erstellen -------------------------------
            $Spiel5 = Create-Button
            $this.Format_Element($Spiel5, 5)
            $Spiel5.text = "Gegen Maschine 2 als O spielen"
            $Spiel5.add_click({
                Open-Gamewindow 2 2
            })
            $this.Window.Controls.Add($Spiel5)

            # AI3 X Button erstellen -------------------------------
            $Spiel6 = Create-Button
            $this.Format_Element($Spiel6, 6)
            $Spiel6.text = "Gegen Maschine 3 als X spielen"
            $Spiel6.add_click({
                Open-Gamewindow 3 1
            })
            $this.Window.Controls.Add($Spiel6)

            # AI3 O Button erstellen -------------------------------
            $Spiel7 = Create-Button
            $this.Format_Element($Spiel7, 7)
            $Spiel7.text = "Gegen Maschine 3 als O spielen"
            $Spiel7.add_click({
                Open-Gamewindow 3 2
            })
            $this.Window.Controls.Add($Spiel7)

            # AI4 X Button erstellen -------------------------------
            $Spiel8 = Create-Button
            $this.Format_Element($Spiel8, 8)
            $Spiel8.text = "Gegen Maschine 4 als X spielen"
            $Spiel8.add_click({
                Open-Gamewindow 4 1
            })
            $this.Window.Controls.Add($Spiel8)

            # AI4 O Button erstellen -------------------------------
            $Spiel9 = Create-Button
            $this.Format_Element($Spiel9, 9)
            $Spiel9.text = "Gegen Maschine 4 als O spielen"
            $Spiel9.add_click({
                Open-Gamewindow 4 2
            })
            $this.Window.Controls.Add($Spiel9)

            # Beenden Button erstellen -----------------------------
            $Back = Create-Button
            $this.Format_Element($Back, 10)
            $Back.text = "Zurück zum Hauptmenü"
            $Back.add_click({
                $Script:Unterfenster.Window.Close()
            })
            $this.Window.Controls.Add($Back)
        }

        [void]show()
            {
                $this.Window.ShowDialog()
            }
               
        [void]Close()
            {
                $this.Window.Close()
            }

        [void]Format_Element($element, $position)
            {
                $ypos = $this.Config.MARGIN_WINDOW + ($this.Config.OBJECT_HEIGHT + $this.Config.MARGIN_OBJECT) * ($position - 1)
                Position-Element $element $this.Config.MARGIN_WINDOW $ypos
                Resize-Element $element $this.Config.OBJECT_WIDTH $this.Config.OBJECT_HEIGHT
            }
    }

# AI Klassen ---------------------------------------------------------------------------------------

<#
    Ist keine AI.
    Wird verwendet um die AI struktur zu umgehen und einen lokalen Mehrspielermodus zu ermöglichen.
#>
class AI_00
    {
        [void]Turn()
            {
                if($Script:Spielfenster.Ended -eq $false)
                    {
                        Write-Host "Spielerwechsel"
                    }
            }
    }

<#
    Unterste Priorität an Zügen.
    Verhindert eine Bestimmte Zwickmühle.
    Ansonsten wird von oben nach unten, von links nach rechts durchgegangen.
#>
class AI_01
    {
        $Feld = $Script:Spielfenster.FeldInhalte
        [void]Turn()
            {
                $gespielt = $false
                $gegner = $Script:Spielfenster.TurnCounter % 2
                if($gegner -eq 0)
                    {
                        $gegner = 2
                    }
                $computerspieler = ($gegner + 1) % 2
                if($computerspieler -eq 0)
                    {
                        $computerspieler = 2
                    }

                # Ecken priorisieren -----------------------------------
                <#
                    Priorisiert die Ecken nur, falls der gegner die Mitte kontrolliert.
                #>
                if($this.Feld[1][1] -eq $gegner)
                    {
                        if($this.Feld[0][0] -eq 0)
                            {
                                $Script:Spielfenster.Place(0, 0)
                                $gespielt = $true
                            }
                        elseif($this.Feld[2][2] -eq 0)
                            {
                                $Script:Spielfenster.Place(2, 2)
                                $gespielt = $true
                            }
                        elseif($this.Feld[0][2] -eq 0)
                            {
                                $Script:Spielfenster.Place(0, 2)
                                $gespielt = $true
                            }
                        elseif($this.Feld[2][0] -eq 0)
                            {
                                $Script:Spielfenster.Place(2, 0)
                                $gespielt = $true
                            }
                    }
                elseif($this.Feld[1][1] -eq $computerspieler)
                    {
                        if($this.Feld[1][2] -eq $gegner -and $this.Feld[2][2] -eq 0)
                            {
                                $Script:Spielfenster.Place(2, 2)
                                $gespielt = $true
                            }
                    }
                

                # Freie Felder finden ----------------------------------
                FOR ($i = 0; $i -lt 3 -and $gespielt -eq $false; $i++)
     	            {
                        FOR ($j = 0; $j -lt 3; $j++)
                            {
                                if($this.Feld[$i][$j] -eq 0 -and $gespielt -eq $false)
                                    {
                                        $Script:Spielfenster.Place($i, $j)
                                        $gespielt = $true
                                    }
                            }
                    }
            }
            
    }

<#
    Erkennt ob die Mitte bereits belegt wurde.
    Falls diese noch nicht belegt wurde, belegt er diese.
    Falls nicht, leitet er den Zug an AI_01 weiter.
#>
class AI_02
    {
        [AI_01]$PrevAI = [AI_01]::new()
        $Feld = $Script:Spielfenster.FeldInhalte
        [void]Turn()
            {
                $gespielt = $false

                # Mitte Belegen ----------------------------------------
                if($this.Feld[1][1] -eq 0)
                    {
                        $Script:Spielfenster.Place(1, 1)
                            $gespielt = $true
                    }

                # Restliche Logik --------------------------------------
                if($gespielt -eq $false)
                    {
                        $this.PrevAI.Turn()
                    }
            }
    }

<#
    Geht alle Spalten der Reihe nach durch.
    Falls er eine Findet, in der zwei gleiche Symbole und ein Leeres Feld sind, belegt er dieses.
    Dies wird entweder das Spiel gewinnen oder einen Sieg des Gegners verhindern.
    Falls dies nicht gegeben ist, leitet er den Zug an AI_02 weiter.
#>
class AI_03
    {
        [AI_02]$PrevAI = [AI_02]::new()
        $Feld = $Script:Spielfenster.FeldInhalte

        [void]Turn()
            {
                $gespielt = $false

                FOR($i = 0; $i -lt 3; $i++)
                    {
                        # Zählen der Elemente in der Spalte --------------------
                        $fill_counter = 0
                        FOR($j = 0; $j -lt 3 -and $gespielt -eq $false; $j++)
                            {
                                if($this.Feld[$i][$j] -ne 0)
                                    {
                                        $fill_counter++
                                    }
                            }
                        
                        # Bearbeitung von Zeilen mit genau 2 Elementen ---------
                        if($fill_counter -eq 2)
                            {
                                <#
                                    Es ist gegeben, dass 2 Elemente nicht 0 sind.
                                    Daher kann das -eq nicht daher kommen, dass beide leer sind.
                                    Ebenfalls ist gegeben, dass genau 1 Feld leer ist.
                                    Falls es also zu einem -eq kommt, ist die Zeile Spielentscheidend.
                                #>
                                if( $this.Feld[$i][0] -eq $this.Feld[$i][1] -or `
                                    $this.Feld[$i][0] -eq $this.Feld[$i][2] -or `
                                    $this.Feld[$i][1] -eq $this.Feld[$i][2])
                                    {
                                        # Durchgehen von links nach rechts um das leere Feld zu finden.
                                        FOR($j = 0; $j -lt 3; $j++)
                                            {
                                                if($this.Feld[$i][$j] -eq 0)
                                                    {
                                                        $Script:Spielfenster.Place($i, $j)
                                                        $gespielt = $true
                                                    }
                                            }
                                    }
                            }
                    }
                    
                # Restliche Logik --------------------------------------
                if($gespielt -eq $false)
                    {
                        $this.PrevAI.Turn()
                    }
            }
    }

<#
    Geht alle Zeilen der Reihe nach durch.
    Falls er eine Findet, in der zwei gleiche Symbole und ein Leeres Feld sind, belegt er dieses.
    Dies wird entweder das Spiel gewinnen oder einen Sieg des Gegners verhindern.
    Falls dies nicht gegeben ist, leitet er den Zug an AI_03 weiter.
    Erklärung der Logik ist in AI_03 zu finden.
#>
class AI_04
    {
        [AI_03]$PrevAI = [AI_03]::new()
        $Feld = $Script:Spielfenster.FeldInhalte

        [void]Turn()
            {
                $gespielt = $false

                # Durchgehen der Elemente in einer Zeile ---------------
                FOR($i = 0; $i -lt 3; $i++)
                    {
                        $fill_counter = 0
                        FOR($j = 0; $j -lt 3 -and $gespielt -eq $false; $j++)
                            {
                                if($this.Feld[$j][$i] -ne 0)
                                    {
                                        $fill_counter++
                                    }
                            }
                        
                        if($fill_counter -eq 2)
                            {
                                if($this.Feld[0][$i] -eq $this.Feld[1][$i] -or $this.Feld[0][$i] -eq $this.Feld[2][$i] -or $this.Feld[1][$i] -eq $this.Feld[2][$i])
                                    {
                                        FOR($j = 0; $j -lt 3; $j++)
                                            {
                                                if($this.Feld[$j][$i] -eq 0)
                                                    {
                                                        $Script:Spielfenster.Place($j, $i)
                                                        $gespielt = $true
                                                    }
                                            }
                                    }
                            }
                    }

                # Restliche Logik --------------------------------------
                if($gespielt -eq $false)
                    {
                        $this.PrevAI.Turn()
                    }
            }
    }

<#
    Geht alle Diagonalen der Reihe nach durch.
    Falls er eine Findet, in der zwei gleiche Symbole und ein leeres Feld sind, belegt er dieses.
    Dies wird entweder das Spiel gewinnen oder einen Sieg des Gegners verhindern.
    Falls dies nicht gegeben ist, leitet er den Zug an AI_04 weiter.
    Es wird in der Logik verstärkt darauf eingegangen, dass jede Diagonale durch 1,1 verläuft.
#>
class AI_05
    {
        [AI_04]$PrevAI = [AI_04]::new()
        $Feld = $Script:Spielfenster.FeldInhalte

        [void]Turn()
            {
                $gespielt = $false

                # Links oben nach Rechts unten -------------------------
                $fill_counter = 0
                FOR($i = 0; $i -lt 3; $i++)
                    {
                        if($this.Feld[$i][$i] -ne 0)
                            {
                                $fill_counter++
                            }
                    }
                if($fill_counter -eq 2)
                    {
                        # Kein vergleich von 0,0 mit 2,2 nötig, da 1,1 immer gefüllt ist.
                        if($this.Feld[0][0] -eq $this.Feld[1][1] -or $this.Feld[1][1] -eq $this.Feld[2][2])
                            {
                                if($this.Feld[0][0] -eq 0)
                                    {
                                        $Script:Spielfenster.Place(0, 0)
                                        $gespielt = $true
                                    }
                                elseif($this.Feld[2][2] -eq 0)
                                    {
                                        $Script:Spielfenster.Place(2, 2)
                                        $gespielt = $true
                                    }
                            }
                    }

                # Rechts oben nach Links unten -------------------------
                $fill_counter = 0
                FOR($i = 0; $i -lt 3; $i++)
                    {
                        if($this.Feld[$i][2-$i] -ne 0)
                            {
                                $fill_counter++
                            }
                    }
                if($fill_counter -eq 2 -and $gespielt -eq $false)
                    {
                        if($this.Feld[0][2] -eq $this.Feld[1][1] -or $this.Feld[1][1] -eq $this.Feld[2][0])
                            {
                                if($this.Feld[0][2] -eq 0)
                                    {
                                        $Script:Spielfenster.Place(0, 2)
                                        $gespielt = $true
                                    }
                                elseif($this.Feld[2][0] -eq 0)
                                    {
                                        $Script:Spielfenster.Place(2, 0)
                                        $gespielt = $true
                                    }
                            }
                    }
                
                # Restliche Logik --------------------------------------
                if($gespielt -eq $false)
                    {
                        $this.PrevAI.Turn()
                    }
            }
        }

<#
    Geht alle Diagonalen, Zeilen und dann Spalten durch.
    Sucht in diesen heraus, wo er spielen kann um sofort zu gewinnen.
#>
class AI_06
    {
        [AI_05]$PrevAI = [AI_05]::new()
        $Feld = $Script:Spielfenster.FeldInhalte

        [void]Turn()
            {
                $gespielt = $false
                $gegner = $Script:Spielfenster.TurnCounter % 2
                if($gegner -eq 0)
                    {
                        $gegner = 2
                    }
                $computerspieler = ($gegner + 1) % 2
                if($computerspieler -eq 0)
                    {
                        $computerspieler = 2
                    }

                # Links oben nach Rechts unten -------------------------
                $fill_counter = 0
                FOR($i = 0; $i -lt 3; $i++)
                    {
                        if($this.Feld[$i][$i] -ne 0)
                            {
                                $fill_counter++
                            }
                    }
                if($fill_counter -eq 2 -and $this.Feld[1][1] -eq $computerspieler)
                    {
                        # Kein vergleich von 0,0 mit 2,2 nötig, da 1,1 immer gefüllt ist.
                        if($this.Feld[0][0] -eq $this.Feld[1][1] -or $this.Feld[1][1] -eq $this.Feld[2][2])
                            {
                                if($this.Feld[0][0] -eq 0)
                                    {
                                        $Script:Spielfenster.Place(0, 0)
                                        $gespielt = $true
                                    }
                                elseif($this.Feld[2][2] -eq 0)
                                    {
                                        $Script:Spielfenster.Place(2, 2)
                                        $gespielt = $true
                                    }
                            }
                    }

                # Rechts oben nach Links unten -------------------------
                $fill_counter = 0
                FOR($i = 0; $i -lt 3; $i++)
                    {
                        if($this.Feld[$i][2-$i] -ne 0)
                            {
                                $fill_counter++
                            }
                    }
                if($fill_counter -eq 2 -and $gespielt -eq $false -and $this.Feld[1][1] -eq $computerspieler)
                    {
                        if($this.Feld[0][2] -eq $this.Feld[1][1] -or $this.Feld[1][1] -eq $this.Feld[2][0])
                            {
                                if($this.Feld[0][2] -eq 0)
                                    {
                                        $Script:Spielfenster.Place(0, 2)
                                        $gespielt = $true
                                    }
                                elseif($this.Feld[2][0] -eq 0)
                                    {
                                        $Script:Spielfenster.Place(2, 0)
                                        $gespielt = $true
                                    }
                            }
                    }
                
                # Zeilen Logik -----------------------------------------
                FOR($i = 0; $i -lt 3; $i++)
                    {
                        $fill_counter = 0
                        FOR($j = 0; $j -lt 3 -and $gespielt -eq $false; $j++)
                            {
                                if($this.Feld[$j][$i] -ne 0)
                                    {
                                        $fill_counter++
                                    }
                            }
                        
                        if($fill_counter -eq 2)
                            {
                                # Der erste Teil prüft, ob eine Zeile relevant ist.
                                # Der zweite Teil der Abfrage prüft, ob es sich um eine Zeile handelt,
                                # welche vom Computer controlliert wird.
                                if(($this.Feld[0][$i] -eq $this.Feld[1][$i]`                                    -or $this.Feld[0][$i] -eq $this.Feld[2][$i]`                                    -or $this.Feld[1][$i] -eq $this.Feld[2][$i])`                                -and (`                                    $this.Feld[0][$i] -eq $computerspieler`                                    -or $this.Feld[1][$i] -eq $computerspieler))
                                    {
                                        FOR($j = 0; $j -lt 3; $j++)
                                            {
                                                if($this.Feld[$j][$i] -eq 0)
                                                    {
                                                        $Script:Spielfenster.Place($j, $i)
                                                        $gespielt = $true
                                                    }
                                            }
                                    }
                            }
                    }

                # Spalten Logik ----------------------------------------
                FOR($i = 0; $i -lt 3; $i++)
                    {
                        # Zählen der Elemente in der Spalte --------------------
                        $fill_counter = 0
                        FOR($j = 0; $j -lt 3 -and $gespielt -eq $false; $j++)
                            {
                                if($this.Feld[$i][$j] -ne 0)
                                    {
                                        $fill_counter++
                                    }
                            }
                        
                        # Bearbeitung von Zeilen mit genau 2 Elementen ---------
                        if($fill_counter -eq 2)
                            {
                                if(($this.Feld[$i][0] -eq $this.Feld[$i][1] -or `
                                    $this.Feld[$i][0] -eq $this.Feld[$i][2] -or `
                                    $this.Feld[$i][1] -eq $this.Feld[$i][2])`
                                -and ($this.Feld[$i][0] -eq $computerspieler`                                    -or $this.Feld[$i][1] -eq $computerspieler))
                                    {
                                        # Durchgehen von links nach rechts um das leere Feld zu finden.
                                        FOR($j = 0; $j -lt 3; $j++)
                                            {
                                                if($this.Feld[$i][$j] -eq 0)
                                                    {
                                                        $Script:Spielfenster.Place($i, $j)
                                                        $gespielt = $true
                                                    }
                                            }
                                    }
                            }
                    }

                # Restliche Logik --------------------------------------
                if($gespielt -eq $false)
                    {
                        $this.PrevAI.Turn()
                    }
            }
        }

####################################################################################################


# Fensterfunktionen ################################################################################
# Scriptvariablen ----------------------------------------------------------------------------------

<#
    Spielfenster:        Hält das Spielfenster.
    Unterfenster:        Hält das Untermenü
    Configuration:       Hält die Konfigurationsdaten.
    ConfigurationWindow: Hält das Fenster mit den Konfigurationseinstellungen.
    AI:                  Hält die AI
#>
$Spielfenster = 0
$Unterfenster = 0
$ConfigurationFeld = [FeldConfig]::new()
$ConfigurationMenu = [MenuConfig]::new()
$ConfigurationWindow = 0
$AI = [AI_00]::new()

# Fenster Erstellen --------------------------------------------------------------------------------

# Öffnet das Hauptmenü.
Function Open-Mainwindow
    {
        
        $Script:Hauptfenster = [MainWindow]::new()
        $Script:Hauptfenster.Show()
    }

# Öffnet ein Fenster mit dem Spiel.
Function Open-Gamewindow
    {
        param(
            [parameter(position=0)][Int]$AI_Code,
            [parameter(position=1)][Int]$Player_Code
        )
        
        # Fenster generieren
        $Script:Spielfenster = [Feld]::new()

        # AI generieren
        if($AI_Code -eq 0)
            {
                $Script:AI = [AI_00]::new()
            }
        elseif($AI_Code -eq 1)
            {
                $Script:AI = [AI_01]::new()
            }
        elseif($AI_Code -eq 2)
            {
                $Script:AI = [AI_02]::new()
            }
        elseif($AI_Code -eq 3)
            {
                $Script:AI = [AI_03]::new()
            }
        elseif($AI_Code -eq 4)
            {
                $Script:AI = [AI_04]::new()
            }
        elseif($AI_Code -eq 5)
            {
                $Script:AI = [AI_05]::new()
            }
        elseif($AI_Code -eq 6)
            {
                $Script:AI = [AI_06]::new()
            }

        # AI bei Bedarf den ersten Zug lassen.
        if($Player_Code -eq 2)
            {
                $AI.Turn()
            }

        # Fenster anzeigen
        $Script:Spielfenster.Show()
    }

# Öffnet ein Untermenü mit den Test-AIs
Function Open-Submenu
    {
        $Script:Unterfenster = [SubmenuWindow]::new()
        $Script:Unterfenster.show()
    }

Function Open-Configmenu
    {
        $Script:ConfigurationWindow = [ConfigWindow]::new()
        $Script:ConfigurationWindow.show()
    }

Function Close-Configmenu
    {
        $Script:ConfigurationWindow.Window.Close()
        $Script:Hauptfenster.Refresh()
    }

# Interaktion mit dem Spiel ------------------------------------------------------------------------

# Rerouting des Buttoninputs.
Function Perform-Action
    {
        param(
            $x,
            $y
        )

        # Spieler Zug
        $Spielfenster.Place($x, $y)

        # Computer Zug
        if($Script:Spielfenster.Ended -eq $false)
            {
                $AI.Turn()
            }
        
    }

####################################################################################################


# Hauptfenster #####################################################################################
# Scriptvariablen ----------------------------------------------------------------------------------

$Hauptfenster = 0

Open-Mainwindow

####################################################################################################