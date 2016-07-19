
function GetSiteDetails($SITE)
{
  switch($SITE)
  {
  "US" { 
       $SiteDetails= @{
       "Site1DCServer1"="YktHstDel01.hosting.cloud.advent";
       "Site1DCServer2"="YktHstDel02.hosting.cloud.advent";
       "Site1SFServer1"="YktHstSF01.hosting.cloud.advent";
       "Site1SFServer2"="YktHstSF02.hosting.cloud.advent";
       "Site2DCServer1"="HrsHstDel01.hosting.cloud.advent";
       "Site2DCServer2"="HrsHstDel02.hosting.cloud.advent";
       "Site2SFServer1"="HrsHstSF01.hosting.cloud.advent";
       "Site2SFServer2"="HrsHstSF02.hosting.cloud.advent";
       "Site1CitrixSiteName"="ControllerYKT";
       "Site2CitrixSiteName"="ControllerHRS";
                      }
       }
  "EMEA" {
      $SiteDetails = @{
       "Site1DCServer1"="EMEA1HstDel01.hosting.cloud.advent";
       "Site1DCServer2"="EMEA1HstDel02.hosting.cloud.advent";
       "Site1SFServer1"="EMEA1HstSF01.hosting.cloud.advent";
       "Site1SFServer2"="EMEA1HstSF02.hosting.cloud.advent";
       "Site2DCServer1"="EMEA2HstDel01.hosting.cloud.advent";
       "Site2DCServer2"="EMEA2HstDel02.hosting.cloud.advent";
       "Site2SFServer1"="EMEA2HstSF01.hosting.cloud.advent";
       "Site2SFServer2"="EMEA2HstSF02.hosting.cloud.advent";
       "Site1CitrixSiteName"="YorktownHeights";
       "Site2CitrixSiteName"="HarrisonHeights";
                     }
         }
  }
return $SiteDetails
}
Export-ModuleMember -Function GetSiteDetails