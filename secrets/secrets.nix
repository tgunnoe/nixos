let
  arrakis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIOSrAgjlB6X6S1EKx/PTwA8sh+fpdFOsu0ZI/bWWq5 root@arrakis";
  rakis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAtrWwUuEENiqU5L4DHx1v7JPQhX7wmLk728jfOLjn4 root@nixos";
  sietch-tabr = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVEsHJbtMGOJsZ3ylesc+UcOnCEMiO7TvMWzcUq5weD root@nixos";
  chapterhouse = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFDl2VfaujPdouzZ+CXLy04puRRYrlBcvIRekuH2Beq root@chapterhouse";
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDLJV7dVWtrSUOV/N3/2lgn3QIjIFVtKBCJE6bQjAWCB tgunnoe@gnu.lv";
  tgunnoe = [ arrakis chapterhouse rakis sietch-tabr user ];
in
{
  "tgunnoe.age".publicKeys = tgunnoe;
  "root.age".publicKeys = tgunnoe;
  "salusa.age".publicKeys = tgunnoe;
}
