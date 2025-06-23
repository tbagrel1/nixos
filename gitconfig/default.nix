{ mutate }:
{
  default = mutate ./gitconfig {
    gitignore = ./gitignore;
  };
  tweag = mutate ./gitconfig-tweag {};
}
