var PointsTableWithFlash = React.createClass({
  handleShowFlash: function(header, text) {
    this.refs.flash.showFlash(header, text);
  },
  render: function() {
    return (
      <div>
        <Flash ref="flash" delay={ this.props.flashDelay } />
        <PointsTable showFlash={ this.handleShowFlash } { ...this.props }/>
      </div>
    );
  }
});

var Flash = React.createClass({
  showFlash: function (header, text) {
    this.setState({
      visible: true,
      header: header,
      text: text
    });
    setTimeout(this.hideFlash, this.props.delay);
  },
  hideFlash: function() {
    this.setState({visible: false});
  },
  getInitialState: function() {
    return {visible: false};
  },
  render: function() {
    return (
      <div className={this.state.visible? "flash" : "invisible"} ref="flash">
        <h1>{ this.state.header }</h1>
        <p>{ this.state.text }</p>
      </div>
    );
  }
});

var PointsTable = React.createClass({
  handlePointSubmit: function() {
    this.refs.tableBody.loadPointsFromServer();
  },
  render: function() {
    return (
      <form>
        <table>
          <PointsTableHeader
            { ...this.props }
            onPointSubmit={ this.handlePointSubmit } />

          <PointsTableBody
            { ...this.props }
            ref="tableBody"
            onPointSubmit={ this.handlePointSubmit } />
        </table>
      </form>
    );
  }
});

var PointsTableHeader = React.createClass({
  render: function() {
    return (
      <thead>
        <tr>
          <td>id</td>
          <td>Адрес</td>
          <td>Координаты</td>
          <td>Новая?</td>
          <td>Рейтинг</td>
          <td>Комментарий</td>
          <td></td>
        </tr>
        <PointsTableAddForm { ...this.props } />
      </thead>
    );
  }
});

var PointsTableAddForm = React.createClass({
  createPoint: function(point) {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      type: 'POST',
      cache: false,
      headers: {
        "Accept": "application/vnd.api+json",
        "Content-Type": "application/vnd.api+json;charset=utf-8"
      },
      data: JSON.stringify(point),
      success: function(data) {
        this.props.onPointSubmit();
      }.bind(this),
      error: function(xhr, status, err) {
        this.props.showFlash(this.props.url + ": " + status, err.toString());
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  handleSubmit: function(e) {
    e.preventDefault();
    var address = React.findDOMNode(this.refs.address.refs.address).value.trim();
    var lat = React.findDOMNode(this.refs.coordinates.refs.lat).value.trim();
    var lon = React.findDOMNode(this.refs.coordinates.refs.lon).value.trim();
    var comment = React.findDOMNode(this.refs.comment.refs.comment).value.trim();

    if (!address || !(lat && lon)) {
      return;
    }
    this.createPoint({
        address: address,
        coordinates: {lat: lat, lon: lon},
        // predefined: true,
        // votes: 1000,
        comment: comment
      });
    React.findDOMNode(this.refs.address.refs.address).value = '';
    React.findDOMNode(this.refs.coordinates.refs.lat).value = '';
    React.findDOMNode(this.refs.coordinates.refs.lon).value = '';
    React.findDOMNode(this.refs.comment.refs.comment).value = '';
    return;
  },
  render: function() {
    return (
      <tr>
        <td><PointsFieldId ref="id" editMode={true} /></td>
        <td><PointsFieldAddress ref="address" editMode={true} /></td>
        <td><PointsFieldCoordinates ref="coordinates" editMode={true} /></td>
        <td>
          <PointsFieldPredefined ref="predefined" editMode={true}>
            {true}
          </PointsFieldPredefined>
        </td>
        <td><PointsFieldVotes ref="votes" editMode={true} /></td>
        <td><PointsFieldComment ref="comment" editMode={true} /></td>
        <td>
          <input type="button"
            value="Добавить"
            onClick={ this.handleSubmit } />
        </td>
      </tr>
    );
  }
});

var PointsFieldId = React.createClass({
  render: function() {
    if (this.props.editMode) {
      return (
        <input type="number"
          defaultValue={ this.props.children }
          placeholder={ this.props.children || "SecureRandom.hex(24)" }
          disabled={true} />
        )
    } else {
      return (<p>{ this.props.children }</p>)
    }
  }
});

var PointsFieldAddress = React.createClass({
  render: function() {
    if (this.props.editMode) {
      return (
        <input type="text"
          defaultValue={ this.props.children }
          placeholder={ this.props.children || "Москва, ул. Щепкина, д. 10" }
          size="25"
          ref="address" />
        )
    } else {
      return (<p>{ this.props.children }</p>)
    }
  }
});

var PointsFieldCoordinates = React.createClass({
  render: function() {
    if (this.props.editMode) {
      return (
        <fieldset className="coordinates">
        &#123; 
        <input type="number"
          defaultValue={ this.props.lat }
          key="lat"
          ref="lat"
          size="7"
          placeholder={ this.props.lat || "14.107" } />
        , 
        <input type="number"
          defaultValue={ this.props.lon }
          key="lon"
          ref="lon"
          size="7"
          placeholder={ this.props.lon || "32.234" } /> 
        &#125;
        </fieldset>
      )
    } else {
      return (
        <p>
          &#123; 
          { this.props.lat }, 
          { this.props.lon } 
          &#125;
        </p>
      )
    }
  }
});

var PointsFieldPredefined = React.createClass({
  render: function() {
    if (this.props.editMode) {
      return (
        <input type="checkbox"
          checked={ this.props.children }
          disabled={true} />
        )
    } else {
      return (
        <input type="checkbox"
          checked={ this.props.children }
          disabled={true} />
        )
    }
  }
});

var PointsFieldVotes = React.createClass({
  render: function() {
    if (this.props.editMode) {
      return (
        <input type="number"
          defaultValue={ this.props.children }
          placeholder={ this.props.children || "1000" }
          disabled={true} />
        )
    } else {
      return (<p>{ this.props.children }</p>)
    }
  }
});

var PointsFieldComment = React.createClass({
  render: function() {
    if (this.props.editMode) {
      return (
        <textarea
          cols="20" rows="1"
          defaultValue={ this.props.children }
          placeholder={ this.props.children || "На 2-ом этаже ТЦ" }
          ref="comment" />
        )
    } else {
      return (<p>{ this.props.children }</p>)
    }
  }
});

var PointsTableBody = React.createClass({
  loadPointsFromServer: function() {
    $.ajax({
      url: this.props.url,
      cache: false,
      headers: {
        "Accept": "application/vnd.api+json",
        "Content-Type": "application/vnd.api+json;charset=utf-8"
      },
      success: function(data) {
        this.setState(data);
      }.bind(this),
      error: function(xhr, status, err) {
        this.props.showFlash(this.props.url + ": " + status, err.toString());
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {points: []};
  },
  componentDidMount: function() {
    this.loadPointsFromServer();
    // setInterval(this.loadPointsFromServer, this.props.pollInterval);
  },
  render: function() {
    var baseUrl = this.props.url;
    var onPointSubmit = this.props.onPointSubmit;
    var showFlash = this.props.showFlash;

    var pointsTableRows = this.state.points.map(function(point) {
      return (
        <PointsTableRow
          url={ baseUrl + "/" + point._id.$oid }
          key={ point._id.$oid }
          point={ point }
          showFlash={ showFlash }
          onPointSubmit={ onPointSubmit } />
      );
    });

    return (
      <tbody>
        { pointsTableRows }
      </tbody>
    );
  }
});

var PointsTableRow = React.createClass({
  deletePoint: function(e) {
    e.preventDefault();
    if (confirm("Delete point " + this.state.point._id.$oid + " ?" )) {
      $.ajax({
        url: this.props.url,
        type: 'DELETE',
        cache: false,
        headers: {
          "Accept": "application/vnd.api+json",
          "Content-Type": "application/vnd.api+json;charset=utf-8"
        },
        success: function(data) {
          this.props.onPointSubmit();
        }.bind(this),
        error: function(xhr, status, err) {
          this.props.showFlash(this.props.url + ": " + status, err.toString());
          console.error(this.props.url, status, err.toString());
        }.bind(this)
      });
    }
  },
  savePoint: function(e) {
    e.preventDefault();
    var address = React.findDOMNode(this.refs.address.refs.address).value.trim();
    var lat = React.findDOMNode(this.refs.coordinates.refs.lat).value.trim();
    var lon = React.findDOMNode(this.refs.coordinates.refs.lon).value.trim();
    var comment = React.findDOMNode(this.refs.comment.refs.comment).value.trim();

    if (!address || !(lat && lon)) {
      return;
    }
    $.ajax({
      url: this.props.url,
      type: 'PATCH',
      cache: false,
      headers: {
        "Accept": "application/vnd.api+json",
        "Content-Type": "application/vnd.api+json;charset=utf-8"
      },
      data: JSON.stringify({
        address: address,
        coordinates: {
          lat: lat,
          lon: lon
        },
        comment: comment
      }),
      success: function(data) {
        this.setState({ editMode: false, point: data });
        this.props.onPointSubmit();
      }.bind(this),
      error: function(xhr, status, err) {
        this.props.showFlash(this.props.url + ": " + status, err.toString());
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  editPoint: function(e) {
    e.preventDefault();
    this.setState({ editMode: true, point: this.state.point });
  },
  cancelPoint: function(e) {
    e.preventDefault();
    if (confirm("Cancel editing?")) {
      this.setState({ editMode: false, point: this.state.point });
    }
  },
  getInitialState: function() {
    return {
      editMode: false,
      point: this.props.point
    };
  },
  render: function() {
    var rowButtons = [
      <input type="button" key="edit" value="E" onClick={ this.editPoint } />,
      <input type="button" key="delete" value="D" onClick={ this.deletePoint } />
    ];

    if (this.state.editMode) {
      rowButtons = [
        <input type="button" key="save" value="S" onClick={ this.savePoint } />,
        <input type="button" key="cancel" value="C" onClick={ this.cancelPoint } />
      ];
    };
    return (
      <tr>
        <td>
          <PointsFieldId ref="id" editMode={ this.state.editMode }>
            { this.state.point._id.$oid }
          </PointsFieldId>
        </td>
        <td>
          <PointsFieldAddress ref="address" editMode={ this.state.editMode }>
            { this.state.point.address }
          </PointsFieldAddress>
        </td>
        <td>
          <PointsFieldCoordinates
            ref="coordinates"
            editMode={ this.state.editMode }
            lat={ this.state.point.coordinates.lat }
            lon={ this.state.point.coordinates.lon } />
        </td>
        <td>
          <PointsFieldPredefined ref="predefined" editMode={ this.state.editMode }>
            {this.state.point.predefined}
          </PointsFieldPredefined>
        </td>
        <td>
          <PointsFieldVotes ref="votes" editMode={ this.state.editMode }>
            { this.state.point.votes }
          </PointsFieldVotes>
        </td>
        <td>
          <PointsFieldComment ref="comment" editMode={ this.state.editMode }>
            { this.state.point.comment }
          </PointsFieldComment>
        </td>
        <td>{ rowButtons }</td>
      </tr>
    );
  }
});

React.render(
  <PointsTableWithFlash
    url="/api/v1/points"
    pollInterval={5000}
    flashDelay={5000} />,
  document.getElementById('content')
);
