    # TODO: Finish this so that it can be easily invoked as a scheduled task per-user.
    
    $source_path = $env:LOCALAPPDATA + "\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets\"
    $dest_path = "C:\DesktopBackgrounds\"
    $blacklist_file = "C:\DesktopBackgrounds\blacklist.txt"
    $min_hres = 1920

    $hash_list = @()
    $hash_list += Get-Content $blacklist_file

    # Get Hashes from Destination Folder (to prevent recycled duplicates)
    Get-ChildItem -Path $dest_path | % {
        $hash_list += (Get-FileHash $_.FullName).Hash
    }

    Get-ChildItem -Path $source_path | % { 
        try { 
            $file_hash = (Get-FileHash $_.FullName).Hash
            if ($hash_list -notcontains $file_hash) { 
                $hash_list += $file_hash
                $img = [System.Drawing.Image]::FromFile($source_path + "\" + $_.name); 
                if ($img.Size.width -ge $min_hres) { 
                    Write-Output("Copying`t" + $_.Name + "`t" + $file_hash)
                    copy ($source_path + "\" + $_.name) ($dest_path + "\" + $file_hash + ".jpg")   #Store as the file_hash.jpg for easier black listing by the end-user
                } 
            } else {
                Write-Output("Skipping`t" + $_.Name + "`t" + $file_hash)
            }
        } catch {
            # Silently catch OutOfMemory errors. Sometimes the image isn't actually an image and as a result, throws an obscure error...
        }
    }
