import React from "react";
import Paper from "../Paper/Paper.js";
import { withStyles } from "material-ui/styles";
import PropTypes from "prop-types";

const styles = theme => ({
  button: {
    margin: theme.spacing.unit
  },
  input: {
    display: "none"
  }
});

function app(props) {
  const { classes } = props;
  return (
    <div>
      <Paper />
    </div>
  );
}

app.propTypes = {
  classes: PropTypes.object.isRequired
};

export default withStyles(styles)(app);
